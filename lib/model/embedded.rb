class OrientDB::AR::Embedded
  include ActiveModel::AttributeMethods
  include Comparable

  extend ActiveModel::Translation

  include OrientDB::AR::Attributes
  include OrientDB::AR::Conversion
  include OrientDB::AR::Validations

  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

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
    raise "Not implemented on Embedded models"
  end

  def delete
    raise "Not implemented on Embedded models"
  end

  def saved?
    false
  end

  def deleted?
    false
  end

  def persisted?
    false
  end

  def inspect
    attrs       = attributes.map { |k, v| "#{k}:#{v.inspect}" }.join(' ')
    super_klass = self.class.descends_from_embedded? ? '' : "(#{self.class.superclass.name})"
    %{#<#{self.class.name}#{super_klass}:#{@odocument.rid} #{attrs}>}
  end

  alias :to_s :inspect

  def <=>(other)
    to_s <=> other.to_s
  end

  class << self

    def connection
      OrientDB::AR::Base.connection
    end

    attr_writer :oclass_name

    def oclass_name
      @oclass_name ||= name.to_s
    end

    def oclass
      unless defined?(@oclass)
        options = {}
        unless descends_from_embedded?
          super_oclass          = superclass.oclass
          options[:super]       = super_oclass
          options[:use_cluster] = super_oclass.cluster_ids.first
        end
        @oclass = connection.get_or_create_class oclass_name, options
      end
      @oclass
    end

    def embedded?
      true
    end

    def field(name, type, options = {})
      name = name.to_sym
      if fields.key? name
        puts "Already defined field [#{name}]"
      else
        fields[name] = {:type => type}.update options
      end
    end

    def descends_from_embedded?
      superclass && superclass == OrientDB::AR::Embedded
    end

    def schema!
      fields.each do |field, options|
        oclass.add field, options[:type], options.except(:type)
      end
      self
    end

    def new_document(fields = {})
      oclass
      OrientDB::Document.new connection, oclass_name, fields
    end

    def create(fields = {})
      raise "Not implemented on Embedded models"
    end

    def select(*args)
      raise "Not implemented on Embedded models"
    end

    alias :columns :select

    def where(*args)
      raise "Not implemented on Embedded models"
    end

    def order(*args)
      raise "Not implemented on Embedded models"
    end

    def limit(max_records)
      raise "Not implemented on Embedded models"
    end

    def range(lower_rid, upper_rid = nil)
      raise "Not implemented on Embedded models"
    end

    def all(conditions = {})
      raise "Not implemented on Embedded models"
    end

    def first(conditions = {})
      raise "Not implemented on Embedded models"
    end

    def clear
      raise "Not implemented on Embedded models"
    end

    def new_from_doc(doc)
      klass = doc.getClassName.constantize
      obj   = klass.new
      obj.instance_variable_set "@odocument", doc
      obj
    end

    def new_from_docs(docs)
      docs.map { |doc| new_from_doc doc }
    end
  end

end
