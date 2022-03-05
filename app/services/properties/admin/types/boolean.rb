# frozen_string_literal: true

module Properties
  module Admin
    module Types
      class Boolean < Generic
        def form
          this = self
          section.field(property[:field_name], :boolean) do
            this.visibility(self)
          end
        end

        def show
          form
        end
      end
    end
  end
end
