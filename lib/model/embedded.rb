require 'model/attributes'
require 'model/validations'

class OrientDB::AR::Embedded
  extend ActiveModel::Translation

  include OrientDB::AR::Attributes
  include OrientDB::AR::Conversion
  include OrientDB::AR::Validations

  def initialize(fields = {})
    @odocument          = self.class.new_document fields
    @changed_attributes = {}
    @errors             = ActiveModel::Errors.new(self)
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

  class << self

    attr_writer :oclass_name

    def oclass_name
      @oclass_name ||= name.downcase.gsub('::', '_')
    end

    def oclass
      @oclass ||= connection.get_or_create_class oclass_name
    end

    def fields
      @fields ||= ActiveSupport::OrderedHash.new
    end

    def field(name, type, options = {})
      name = name.to_sym
      if fields.key? name
        puts "Already defined field [#{name}]"
      else
        fields[name] = {:type => type}.update options
      end
    end

    def new_document(fields = {})
      oclass
      OrientDB::Document.new connection, oclass_name, fields
    end

  end
end
