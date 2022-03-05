# frozen_string_literal: true

module Properties
  class Base
    protected

    def type_handler(type)
      raise NameError if type.blank?

      "#{types_namespace}#{type.to_s.camelize}".constantize
    rescue NameError
      "#{types_namespace}Generic".constantize
    end
  end
end
