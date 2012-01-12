module OrientDB::AR
  module Relations

    def embedds_one(klass_name, options = { })
      klass_name, options = check_rel_options klass_name, options, :singular
      name = options[:name]

      relationships[name] = options.merge :type => :embedds_one, :class_name => klass_name

      field name, [OrientDB::FIELD_TYPES[:embedded], OrientDB::AR::Base.oclass_name_for(klass_name)]

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
          self[:#{name}] = #{klass_name}.new fields         #   self[:addresses] = Address.new fields
          #{name}                                           #   address
        end                                                 # end
      eorb
    end

  end
end