class OrientDB::AR::Embedded

  include ActiveModel::AttributeMethods
  include OrientDB::AR::DocumentMixin

  define_model_callbacks :validation

  def save
    raise "Not implemented on Embedded models"
  end

  def delete
    raise "Not implemented on Embedded models"
  end

  def reload
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

    include OrientDB::AR::Relations

    def embeddable?
      true
    end

    def connection
      OrientDB::AR::Base.connection
    end

    def oclass
      @oclass ||= connection.get_or_create_class oclass_name, fields.dup
    end

    def descends_from_base?
      superclass && superclass == OrientDB::AR::Embedded
    end

    def schema!
      raise "Not implemented on Embedded models"
    end

    def create(fields = { })
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

    def all(conditions = { })
      raise "Not implemented on Embedded models"
    end

    def first(conditions = { })
      raise "Not implemented on Embedded models"
    end

    def update(*args)
      raise "Not implemented on Embedded models"
    end

    def delete(*args)
      raise "Not implemented on Embedded models"
    end

    def insert(*args)
      raise "Not implemented on Embedded models"
    end

    def count
      raise "Not implemented on Embedded models"
    end

    def clear
      raise "Not implemented on Embedded models"
    end
  end
end
