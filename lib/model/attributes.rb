require 'active_support/core_ext/hash/indifferent_access'

module OrientDB::AR
  module Attributes

    def attribute_names
      schema_names = self.class.fields.keys.map { |x| x.to_s }
      (schema_names + @odocument.field_names.map).uniq
    end

    def attributes
      attribute_names.inject({}) { |h, attr| h[attr.to_s] = self[attr]; h }
    end

    def [](attr)
      res = @odocument[attr]
      res.respond_to?(:jruby_value) ? res.jruby_value : res
    end

    def []=(attr, value)
      old_value = self[attr]
      return old_value if value == old_value
      attribute_will_change!(attr)
      @odocument[attr] = value
    end

    def changed?
      !changed_attributes.empty?
    end

    def changed
      changed_attributes.keys
    end

    def changes
      changed.inject(HashWithIndifferentAccess.new) { |h, attr| h[attr] = attribute_change(attr); h }
    end

    def previous_changes
      @previously_changed
    end

    def changed_attributes
      @changed_attributes ||= HashWithIndifferentAccess.new
    end

    private

    def attribute_changed?(attr)
      changed_attributes.include?(attr)
    end

    def attribute_change(attr)
      [changed_attributes[attr], @odocument[attr]] if attribute_changed?(attr)
    end

    def attribute_was(attr)
      attribute_changed?(attr) ? changed_attributes[attr] : @odocument[attr]
    end

    def attribute_will_change!(attr)
      return if attribute_changed?(attr)

      begin
        value = @odocument[attr]
        value = value.duplicable? ? value.clone : value
      rescue TypeError, NoMethodError
      end

      changed_attributes[attr] = value
    end

    def reset_attribute!(attr)
      @odocument[attr] = changed_attributes[attr] if attribute_changed?(attr)
    end

  end
end