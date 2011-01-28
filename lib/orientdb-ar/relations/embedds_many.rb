module OrientDB::AR
  module Relations

    def embedds_many(klass, options = { })
      klass               = klass_for klass
      name                = field_name_for options, klass, false
      options[:default]   ||= []

      relationships[name] = options.merge :type => :embedds_many, :class_name => klass.name

      field name, [OrientDB::FIELD_TYPES[:embedded_list], klass.oclass]

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
        def add_#{name.singularize}(value)                  # def add_address(value)
          self[:#{name}] ||= #{options[:default].inspect}   #   self[:addresses] ||= []
          self[:#{name}] << self.class.to_orientdb(value)   #   self[:addresses] << self.class.to_orientdb(value)
          #{name}                                           #   addresses
        end                                                 # end
      eorb

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def build_#{name}(fields = {})                      # def build_address(fields = {})
          add_#{name} #{klass.name}.new fields              #   self[:addresses] = Address.new fields
        end                                                 # end
      eorb
    end

  end
end