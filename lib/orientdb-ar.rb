require 'rubygems'
require 'active_model'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/kernel'
require 'active_support/core_ext/class/attribute'
require 'orientdb'

module OrientDB
  module AR

    class Base

      include ActiveModel::AttributeMethods

      class_attribute :connection

      attr_reader :odocument

      def initialize(fields = {})
        @odocument = self.class.new_document fields
      end

      def respond_to?(method_name)
        odocument.respond_to?(method_name) || super
      end

      def method_missing(method_name, *args, &blk)
        if odocument.respond_to?(method_name)
          odocument.send method_name, *args, &blk
        else
          super
        end
      end

      class << self

        attr_writer :oclass_name

        def oclass_name
          @oclass_name ||= name.downcase.gsub('::', '_')
        end

        def oclass
          @oclass ||= connection.get_or_create_class oclass_name
        end

        def fields
          @fields ||= ActiveSupport::OrderedHash.new
        end

        def field(name, type, options = {})
          name = name.to_sym
          if fields.key? name
            puts "Already defined field [#{name}]"
          else
            fields[name] = {:type => type}.update options
          end
        end

        def schema!
          fields.each do |field, options|
            oclass.add field, options
          end
        end

        def new_document(fields = {})
          oclass
          OrientDB::Document.new connection, oclass_name, fields
        end

        def create(fields = {})
          obj = new fields
          obj.save
          obj
        end

        def all(options = {})
          options.update :oclass => oclass_name
          connection.all(options).map
        end

        def first(options = {})
          options.update :oclass => oclass_name
          connection.first options
        end

        def query(options = {})
          options.update :oclass => oclass_name
          connection.query(options).map
        end
      end

    end
  end
end