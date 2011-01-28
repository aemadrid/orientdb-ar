module OrientDB::AR
  module Relations

    def embedds_one(klass, options = { })
      klass               = klass_for klass
      name                = field_name_for options, klass, true
      options[:default]   ||= nil

      relationships[name] = options.merge :type => :embedds_one, :class_name => klass.name

      field name, [OrientDB::FIELD_TYPES[:embedded], klass.oclass]

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
        def build_#{name}(fields = {})                      # def build_address(fields = {})
          self[:#{name}] = #{klass.name}.new fields         #   self[:addresses] = Address.new fields
          #{name}                                           #   address
        end                                                 # end
      eorb
    end

  end
end