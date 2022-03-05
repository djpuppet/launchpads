# frozen_string_literal: true

module Properties
  module Admin
    module Types
      class Dropdown < Generic
        def form
          this = self
          section.field(property[:field_name], :enum) do
            this.form_config(self)
          end
        end

        def show
          this = self
          section.field(property[:field_name], :enum) do
            this.visibility(self)
            # noinspection RubyArgCount
            pretty_value do
              this.pretty_value(value)
            end
          end
        end

        def pretty_value(value)
          if property.dig(:options, :multiple)
            value.join(', ')
          else
            value
          end
        end

        def form_config(field)
          options = property[:options]
          visibility(field)
          field.enum do
            options[:values]
          end
          field.multiple(options.fetch(:multiple, false))
        end
      end
    end
  end
end
