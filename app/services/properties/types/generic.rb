# frozen_string_literal: true

module Properties
  module Types
    class Generic
      attr_reader :model_class, :property

      def initialize(property, model_class)
        @property    = property
        @model_class = model_class
      end

      def call
        field_name = property[:field_name]
        model_class.define_method("#{field_name}=", &setter)
        model_class.define_method(field_name, &getter)
      end

      # :reek:UtilityFunction
      def serialize(value)
        value
      end

      # :reek:UtilityFunction
      def deserialize(value)
        value
      end

      private

      def setter
        this = self
        proc do |value|
          instance_variable_set("@#{this.property[:field_name]}", this.serialize(value))
        end
      end

      # :reek:TooManyStatements
      def getter
        this = self
        field_name = property[:field_name]
        proc do
          value = if instance_variable_defined?("@#{field_name}")
                    instance_variable_get("@#{field_name}")
                  else
                    properties.fetch(field_name.to_s, nil)
                  end

          this.deserialize(value)
        end
      end
    end
  end
end
