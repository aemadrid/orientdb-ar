require 'rubygems'
require 'active_model'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/kernel'
require 'active_support/core_ext/class/attribute'
require 'orientdb'

require 'model/conversion'
require 'model/attributes'
require 'model/validations'

class OrientDB::AR::Base
  include ActiveModel::AttributeMethods
  include Comparable

  extend ActiveModel::Translation
  extend ActiveModel::Callbacks

  include OrientDB::AR::Attributes
  include OrientDB::AR::Conversion
  include OrientDB::AR::Validations

  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  define_model_callbacks :save, :delete

  class_attribute :connection

  class_inheritable_hash :fields
  self.fields = ActiveSupport::OrderedHash.new

  attr_reader :odocument

  def initialize(fields = {})
    @odocument          = self.class.new_document fields
    @changed_attributes = {}
    @errors             = ActiveModel::Errors.new(self)
  end

  def field?(name)
    res = @odocument.field?(name)
    res
  end

  def respond_to?(method_name)
    # Simple field value lookup
    return true if field?(method_name)
    # Dirty
    return true if method_name.to_s =~ /(\w*)(_changed\?|_change|_will_change!|_was)$/ && field?($1)
    # Setter
    return true if method_name.to_s =~ /(.*?)=$/
    # Boolean
    return true if method_name.to_s =~ /(.*?)?$/ && field?($1)
    # Unknown pattern
    super
  end

  def method_missing(method_name, *args, &blk)
    # Simple field value lookup
    return self[method_name] if field?(method_name)
    # Dirty
    if method_name.to_s =~ /(\w*)(_changed\?|_change|_will_change!|_was)$/ && field?($1)
      __send__("attribute#{$2}", $1)
      # Setter
    elsif method_name.to_s =~ /(.*?)=$/
      self[$1] = args.first
      # Boolean
    elsif method_name.to_s =~ /(.*?)?$/ && field?($1)
      !!self[$1]
      # Unknown pattern
    else
      super
    end
  end

  def save
    _run_save_callbacks do
      @odocument.save
      @saved              = true
      @previously_changed = @changed_attributes
      @changed_attributes.clear
    end
    true
  end

  def delete
    _run_delete_callbacks do
      @odocument.delete
      @deleted = true
    end
    true
  end

  def saved?
    @saved || @odocument.rid != '-1:-1'
  end

  def deleted?
    @deleted ||= false
  end

  def persisted?
    saved? && !deleted?
  end

  def inspect
    attrs       = attributes.map { |k, v| "#{k}:#{v.inspect}" }.join(' ')
    super_klass = self.class.descends_from_base? ? '' : "(#{self.class.superclass.name})"
    %{#<#{self.class.name}#{super_klass}:#{@odocument.rid} #{attrs}>}
  end

  alias :to_s :inspect

  def <=>(other)
    to_s <=> other.to_s
  end

  class << self

    attr_writer :oclass_name

    def oclass_name
      @oclass_name ||= name.to_s
    end

    def oclass
      unless defined?(@oclass)
        options = {}
        unless descends_from_base?
          super_oclass          = superclass.oclass
          options[:super]       = super_oclass
          options[:use_cluster] = super_oclass.cluster_ids.first
        end
        @oclass = connection.get_or_create_class oclass_name, options
      end
      @oclass
    end

    def field(name, type, options = {})
      name = name.to_sym
      if fields.key? name
        puts "Already defined field [#{name}]"
      else
        fields[name] = {:type => type}.update options
      end
    end

    def descends_from_base?
      superclass && superclass == OrientDB::AR::Base
    end

    def schema!
      fields.each do |field, options|
        oclass.add field, options[:type], options.except(:type)
      end
    end

    def new_document(fields = {})
      oclass
      OrientDB::Document.new connection, oclass_name, fields
    end

    def create(fields = {})
      obj = new fields
      obj.save
      obj
    end

    def select(*args)
      OrientDB::AR::Query.new(self).select(*args)
    end

    alias :columns :select

    def where(*args)
      OrientDB::AR::Query.new(self).where(*args)
    end

    def order(*args)
      OrientDB::AR::Query.new(self).order(*args)
    end

    def limit(max_records)
      OrientDB::AR::Query.new(self).limit(max_records)
    end

    def range(lower_rid, upper_rid = nil)
      OrientDB::AR::Query.new(self).range(lower_rid, upper_rid)
    end

    def all(conditions = {})
      OrientDB::AR::Query.new(self).where(conditions).all
    end

    def first(conditions = {})
      OrientDB::AR::Query.new(self).where(conditions).first
    end

    def clear
      oclass.truncate
    end

    def new_from_doc(doc)
      klass = doc.getClassName.constantize
      obj   = klass.new
      obj.instance_variable_set "@odocument", doc
      obj
    end
  end

end

class OrientDB::AR::Query

  attr_accessor :model, :query

  def initialize(model, query = OrientDB::SQL::Query.new)
    @model, @query = model, query
    @query.from model.name
  end

  %w{ select select! where where! and or and_not or_not order order! limit limit! range range! }.each do |name|
    define_method(name) do |*args|
      query.send name, *args
      self
    end
  end

  def all
    model.connection.query(query).map { |doc| model.new_from_doc doc }
  end

  def first
    model.new_from_doc model.connection.first(query)
  end

  def results
    model.connection.query(query).map
  end

  def inspect
    %{#<OrientDB::AR::Query:#{model.name} query="#{query.to_s}">}
  end

  alias :to_s :inspect

end

OrientDB::AR::Base.include_root_in_json = false