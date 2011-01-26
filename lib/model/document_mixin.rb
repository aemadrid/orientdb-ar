require 'rubygems'
require 'active_model'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/kernel'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/class/inheritable_attributes'
require 'orientdb'

require 'model/conversion'
require 'model/attributes'
require 'model/validations'
require 'model/relations'
require 'model/query'
require 'model/commands'

module OrientDB::AR::DocumentMixin

  include Comparable
  include ActiveModel::AttributeMethods

  include OrientDB::AR::Attributes
  include OrientDB::AR::Conversion
  include OrientDB::AR::Validations

  def self.included(base)
    base.extend ActiveModel::Translation
    base.extend ActiveModel::Callbacks unless base.embeddable?

    base.send :include, ActiveModel::Serializers::JSON
    base.send :include, ActiveModel::Serializers::Xml

    base.extend OrientDB::AR::DocumentMixin::ClassMethods
  end

  attr_reader :odocument

  def initialize(fields = {})
    @odocument          = self.class.new_document
    @changed_attributes = {}
    @errors             = ActiveModel::Errors.new(self)
    fields.each { |k, v| send "#{k}=", v }
  end

  def field?(name)
    @odocument.field?(name)
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

  def inspect
    attrs       = attributes.map { |k, v| "#{k}:#{v.inspect}" }.join(' ')
    super_klass = self.class.descends_from_base? ? '' : "(#{self.class.superclass.name})"
    %{#<#{self.class.name}#{super_klass}:#{@odocument.rid} #{attrs}>}
  end

  alias :to_s :inspect

  def <=>(other)
    to_s <=> other.to_s
  end

  module ClassMethods

    attr_writer :oclass_name

    def oclass_name
      @oclass_name ||= name.to_s.gsub('::', '__')
    end

    def field(name, type, options = {})
      name = name.to_sym
      if fields.key? name
        puts "Already defined field [#{name}]"
      else
        fields[name] = {:type => type}.update options
      end
    end

    def new_document
      OrientDB::Document.new connection, oclass_name
    end
  end

end