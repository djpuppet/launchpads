# frozen_string_literal: true

module Properties
  module Admin
    class Field < Base
      attr_reader :section, :property

      def initialize(section, property)
        super()
        @section = section
        @property = property
      end

      def call
        handler = type_handler(@property[:field_type]).new(section, property)
        handler.send(handler_method)
      end

      protected

      def handler_method
        raise NotImplementedError
      end

      private

      def types_namespace
        'Properties::Admin::Types::'
      end
    end
  end
end
