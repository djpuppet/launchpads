# frozen_string_literal: true

module AuditingObject
  class AuditHandler
    def call(action, args)
      @model_name = args[:model].model_name
      handler_class = find_handler_class
      handler = handler_class.new(args)
      handler.send(action)
    end

    private

    def find_handler_class
      return constantize_handler_name if handler_class_exists?

      AuditingObject::Handlers::Base
    end

    def handler_class_exists?
      Module.const_defined?(handler_class_name)
    end

    def constantize_handler_name
      Module.const_get(handler_class_name)
    end

    def handler_class_name
      "AuditingObject::Handlers::#{@model_name}"
    end
  end
end
