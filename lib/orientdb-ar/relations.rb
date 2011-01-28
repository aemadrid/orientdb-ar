module OrientDB::AR
  module Relations

    private

    def klass_for(klass)
      return klass if klass.class.name == 'Class'
      klass.to_s.singularize.camelize.constantize
    rescue
      raise "Problem getting klass for [#{klass}]"
    end

    def field_name_for(options, klass, singular)
      if options[:name].blank?
        options[:name] = klass.to_s.underscore.send(singular ? :singularize : :pluralize).gsub('/', '__')
      else
        options[:name].to_s
      end
    end

  end
end

require 'orientdb-ar/relations/embedds_one'
require 'orientdb-ar/relations/embedds_many'
require 'orientdb-ar/relations/links_one'
require 'orientdb-ar/relations/links_many'