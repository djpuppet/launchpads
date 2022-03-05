# frozen_string_literal: true

module Properties
  class Attribute < Base
    attr_reader :property, :model_class

    def initialize(property, model_class)
      super()
      @property = property
      @model_class = model_class
    end

    def call
      handler = type_handler(@property[:field_type]).new(property, model_class)
      handler.call
    end

    private

    def types_namespace
      'Properties::Types::'
    end
  end
end
