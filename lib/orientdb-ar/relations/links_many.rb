module OrientDB::AR
  module Relations

    def links_many(klass_name, options = { })
      klass_name, options = check_rel_options klass_name, options, :plural, []
      name = options[:name]

      relationships[name] = options.merge :type => :links_many, :class_name => klass_name

      field name, [OrientDB::FIELD_TYPES[:link_list], OrientDB::AR::Base.oclass_name_for(klass_name)]

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
          add_#{name} #{klass_name}.new fields              #   self[:addresses] = Address.new fields
        end                                                 # end
      eorb

      class_eval <<-eorb, __FILE__, __LINE__ + 1
        def create_#{name}(fields = {})                     # def create_address(fields = {})
          add_#{name} #{klass_name}.create fields           #   self[:addresses] = Address.create fields
        end                                                 # end
      eorb
    end

  end
end