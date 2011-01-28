module OrientDB::AR
  module Relations

    def links_one(klass, options = { })
      klass               = klass_for klass
      name                = field_name_for options, klass, true
      options[:default]   ||= nil

      relationships[name] = options.merge :type => :links_one, :class_name => klass.name

      field name, [OrientDB::FIELD_TYPES[:link], klass.oclass]

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}                                         # def address
          self[:#{name}] || #{options[:default].inspect}    #   self[:address] || nil
        end                                                 # end
      eorb

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def #{name}=(value)                                 # def addresses=(value)
          self[:#{name}] = value                            #   self[:addresses] = value
        end                                                 # end
      eorb

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def create_#{name}(fields = {})                     # def create_address(fields = {})
          self[:#{name}] = #{klass.name}.create fields      #   self[:addresses] = Address.create fields
          #{name}                                           #   address
        end                                                 # end
      eorb
    end

  end
end