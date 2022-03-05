# frozen_string_literal: true

module Properties
  module Admin
    module Types
      class Currency < Generic
        def form
          this = self
          section.field(property[:field_name], :decimal) do
            this.visibility(self)
            this.html_attributes(self)
          end
        end

        def show
          this = self
          section.field(property[:field_name]) do
            this.visibility(self)
          end
        end

        def html_attributes(field)
          field.html_attributes do
            {
              required: required?,
              type:     :number,
              step:     0.01
            }
          end
        end
      end
    end
  end
end
