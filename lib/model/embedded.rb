class OrientDB::AR::Embedded

  def self.embeddable?
    true
  end

  include OrientDB::AR::DocumentMixin

  class_inheritable_hash :fields
  self.fields = ActiveSupport::OrderedHash.new

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

  class << self

    def connection
      OrientDB::AR::Base.connection
    end

    def oclass
      @oclass ||= connection.get_or_create_class oclass_name, fields.dup
    end

    def schema!
      raise "Not implemented on Embedded models"
    end

    def descends_from_base?
      superclass && superclass == OrientDB::AR::Embedded
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
  end

end
