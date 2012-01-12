module OrientDB::AR
  module Relations

    private

    def check_rel_options(klass_name, options, plurality, default = nil)
      klass_name          = klass_name_for klass_name
      options[:plurality] ||= plurality
      options[:name]      ||= field_name_for klass_name, plurality
      options[:name]      = options[:name].to_s
      options[:default]   ||= default
      [klass_name, options]
    end

    def klass_name_for(klass_name)
      return klass_name.name if klass_name.class.name == 'Class'
      klass_name.to_s
    end

    def field_name_for(klass, plurality)
      plurality_meth = plurality.to_s + 'ize'
      klass.to_s.underscore.send(plurality_meth).gsub('/', '__')
    end

  end
end

require 'orientdb-ar/relations/embedds_one'
require 'orientdb-ar/relations/embedds_many'
require 'orientdb-ar/relations/links_one'
require 'orientdb-ar/relations/links_many'
