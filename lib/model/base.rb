class OrientDB::AR::Base

  def self.embeddable?
    false
  end

  include OrientDB::AR::DocumentMixin

  class_inheritable_hash :fields
  self.fields = ActiveSupport::OrderedHash.new

  class_attribute :connection

  define_model_callbacks :save, :delete

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

  class << self

    include OrientDB::AR::Relations

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
      self
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
  end

end

OrientDB::AR::Base.include_root_in_json = false