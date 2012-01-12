require 'rubygems'
require 'active_model'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/kernel'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/module/aliasing'
require 'orientdb'
require 'validatable'

require 'orientdb-ar/conversion'
require 'orientdb-ar/attributes'
require 'orientdb-ar/relations'
require 'orientdb-ar/sql'

module OrientDB::AR::DocumentMixin

  def self.included(base)
    base.class_eval do
      include Comparable

      include Validatable
      alias_method_chain :valid?, :default_group

      include OrientDB::AR::Attributes
      include OrientDB::AR::Conversion

      extend ActiveModel::Translation
      include ActiveModel::Serializers::JSON
      include ActiveModel::Serializers::Xml

      extend ActiveModel::Callbacks

      class_inheritable_hash :fields
      self.fields = ActiveSupport::OrderedHash.new

      class_inheritable_hash :relationships
      self.relationships = ActiveSupport::OrderedHash.new

      class_inheritable_accessor :default_validation_group

      class_attribute :connection
    end
    base.extend OrientDB::AR::DocumentMixin::ClassMethods
  end

  attr_reader :odocument

  def initialize(fields = { })
    @odocument          = self.class.new_document
    @changed_attributes = { }
    @errors             = ActiveModel::Errors.new(self)
    fields.each { |k, v| send "#{k}=", v }
  end

  def human_id
    rid
  end

  def field?(name)
    @odocument.field?(name)
  end

  def validate
    @last_validation_result = nil
    _run_validation_callbacks do
      @last_validation_result = valid?
    end
    @last_validation_result
  end

  def valid_with_default_group?
    valid_for_group?(default_validation_group) && related_valid?
  end

  def related_valid?
    res = related.all? do |rel_name, row_or_coll|
      case row_or_coll
        when Array
          row_or_coll.all? do |result|
            result.validate_to_parent errors, rel_name
          end
        else
          row_or_coll.validate_to_parent errors, rel_name
      end
    end
    res
  end

  def validate_to_parent(parent_errors, rel_name)
    return true if valid?
    errors.full_messages.each { |msg| parent_errors[rel_name] = "#{human_id} #{msg}" }
    false
  end

  def related
    relationships.map do |rel_name, options|
      rel_obj = send options[:name]
      rel_obj.blank? ? nil : [rel_name, rel_obj]
    end.compact
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

  def embedded?
    self.class.embeddable?
  end

  def connection
    self.class.connection
  end

  def oclass
    self.class.oclass
  end

  def oclass_name
    self.class.oclass_name
  end

  def rid
    @odocument.rid
  end

  def inspect
    attrs       = attributes.map { |k, v| "#{k}:#{v.inspect}" }.join(' ')
    super_klass = self.class.descends_from_base? ? '' : "(#{self.class.superclass.name})"
    rid_str     = embedded? ? '(E)' : ":#{@odocument.rid}"
    %{#<#{self.class.name}#{super_klass}#{rid_str} #{attrs}>}
  end

  alias :to_s :inspect

  def <=>(other)
    to_s <=> other.to_s
  end

  module ClassMethods

    attr_writer :oclass_name

    def oclass_name_for(value)
      value.to_s.gsub('::', '__')
    end

    def oclass_name
      @oclass_name ||= oclass_name_for name
    end

    def field(name, type, options = { })
      name = name.to_sym
      if fields.key? name
        puts "Already defined field [#{name}]"
      else
        fields[name] = { :type => type }.update options
      end
    end

    def schema!
      fields.each do |field, options|
        begin
          oclass.add field, options[:type], options.except(:type)
        rescue Exception => e
          raise e unless e.message =~ /already exists/
        end
      end
      self
    end

    def new_document
      OrientDB::Document.new connection, oclass_name
    end

    def from_orientdb(value)
      value.respond_to?(:to_orientdb_ar) ? value.to_orientdb_ar : value
    end

    def to_orientdb(value)
      if value.respond_to?(:to_orientdb)
        value.to_orientdb
      elsif value.respond_to?(:jruby_value)
        value.jruby_value
      else
        value
      end
    end
  end

end