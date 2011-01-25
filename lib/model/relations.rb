module OrientDB::AR
  module Relations

    def embedds_one(klass, options = {})
      klass = klass_for klass
      name = options[:name].to_s || field_name_for(klass, true)

      field name, [OrientDB::FIELD_TYPES[:embedded], klass.oclass]

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}                                                          # def address
          self[:#{name}]                                                     #   self[:address]
        end                                                                  # end
      eorb

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}=(value)                                                  # def address=(value)
          self[:#{name}] = value                                             #   self[:address] = value.odocument
          #{name}                                                            #   address
        end                                                                  # end
      eorb
    end

    def embedds_many(klass, options = {})
      klass = klass_for klass
      name = options[:name].to_s || field_name_for(klass, false)

      field name, [OrientDB::FIELD_TYPES[:embedded_list], klass.oclass]

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}                                         # def addresses
          self[:#{name}]                                    #   self[:addresses]
        end                                                 # end
      eorb

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}=(value)                                 # def addresses=(value)
          puts "#{name}=(\#{value.inspect})"
          self[:#{name}]                                    #   self[:addresses]
        end                                                 # end
      eorb

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def add_#{name.singularize}(value)                  # def add_address(value)
          puts "add_#{name}=(\#{value.inspect})"
          self[:#{name}] ||= []                             #   self[:addresses] ||= []
          self[:#{name}] << value                           #   self[:addresses] << value
          #{name}                                           #   addresses
        end                                                 # end
      eorb
    end

    private

    def klass_for(klass)
      return klass if klass.class.name == 'Class'
      klass.to_s.singularize.camelize.constantize
    rescue
      raise "Problem getting klass for [#{klass}]"
    end

    def field_name_for(klass, singular)
      klass.to_s.underscore.send(singular ? :singularize : :pluralize).gsub('/', '__')
    end

  end
end