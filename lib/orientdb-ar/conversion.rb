module OrientDB::AR
  module Conversion

    def to_model
      self
    end

    def to_key
      persisted? ? @odocument.rid.split(':') : nil
    end

    def to_param
      persisted? ? to_key.join('-') : nil
    end

  end
end