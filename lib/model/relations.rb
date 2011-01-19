module OrientDB::AR
  module Relations

    def has_one(klass, options = {})
      klass = klass_for klass
      name = options[:name].to_s || field_name_for(klass, true)

      field_type = klass.embedded? ? :embedded : :link
      field name, [OrientDB::FIELD_TYPES[field_type], klass.oclass]

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}                                                          # def address
          doc = odocument[:#{name}]                                          #   doc = odocument[:address]
          doc ? #{klass.name}.new_from_doc(doc) : nil                        #   doc ? Address.new_from_doc(doc) : nil
        end                                                                  # end
      eorb
                                                                             #
      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}=(value)                                                  # def address=(value)
          raise "Invalid value for [#{name}]" unless value.is_a?(#{klass})   #   raise "Invalid value for [address]" unless value.is_a?(Address)
          odocument[:#{name}] = value.odocument                              #   odocument[:address] = value.odocument
          #{name}                                                            #   address
        end                                                                  # end
      eorb
    end

    def has_many(klass, options = {})
      klass = klass_for klass
      name = options[:name].to_s || field_name_for(klass, false)

      field_type = klass.embedded? ? :embedded : :link
      field name, [OrientDB::FIELD_TYPES[field_type], klass.oclass]

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}                                         # def addresses
          docs = odocument[:#{name}]                        #   docs = odocument[:addresses]
          docs ? #{klass.name}.new_from_docs(docs) : nil    #   docs ? Address.new_from_docs(doc) : nil
        end                                                 # end
      eorb

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}=(value)                                 # def addresses=(value)
          odocument[:#{name}] = value.map{|x| x.odocument } #   odocument[:addresses] = value.map{|x| x.odocument }
          #{name}                                           #   addresses
        end                                                 # end
      eorb

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def add_#{name.singularize}(value)                 # def add_address(value)
          odocument[:#{name}] << value.odocument            #   odocument[:addresses] << value.odocument
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