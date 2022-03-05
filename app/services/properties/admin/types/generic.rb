# frozen_string_literal: true

module Properties
  module Admin
    module Types
      class Generic
        attr_reader :section, :property

        def initialize(section, property)
          @section  = section
          @property = property
        end

        def form
          this = self
          section.field(property[:field_name]) do
            this.visibility(self)
          end
        end

        def show
          form
        end

        def visibility(field)
          allowed_roles = property[:roles]
          field.visible do
            role = bindings[:object].try(:role)
            !allowed_roles.is_a?(Array) || allowed_roles.include?(role&.to_sym)
          end
        end
      end
    end
  end
end
