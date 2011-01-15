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
    attrs = attributes.map { |k, v| "#{k}:#{v.inspect}" }.join(' ')
    super_klass = self.class.descends_from_base? ? '' : "(#{self.class.superclass.name})"
    %{#<#{self.class.name}#{super_klass}:#{@odocument.rid} #{attrs}>}
  end

  alias :to_s :inspect

  class << self

    attr_writer :oclass_name

    def oclass_name
      @oclass_name ||= name.to_s
    end

    def oclass
      unless defined?(@oclass)
        options = {}
        unless descends_from_base?
          super_oclass = superclass.oclass
          options[:super] = super_oclass
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

    def all(options = {})
      options.update :oclass => oclass_name
      connection.all(options).map{|doc| new_from_doc doc }
    end

    def first(options = {})
      options.update :oclass => oclass_name
      new_from_doc connection.first(options)
    end

    def query(options = {})
      options.update :oclass => oclass_name
      connection.query(options).map{|doc| new_from_doc doc }
    end

    def new_from_doc(doc)
      klass = doc.getClassName.constantize
      obj = klass.new
      obj.instance_variable_set "@odocument", doc
      obj
    end
  end

end

OrientDB::AR::Base.include_root_in_json = false