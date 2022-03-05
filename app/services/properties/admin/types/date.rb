# frozen_string_literal: true

module Properties
  module Admin
    module Types
      class Date < Generic
        def form
          this = self
          section.field(property[:field_name], :date) do
            this.visibility(self)
            formatted_value do
              I18n.l(value, format: :long) if value.present?
            end
          end
        end

        def show
          form
        end
      end
    end
  end
end
