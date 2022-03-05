# frozen_string_literal: true

module Properties
  module Admin
    module Types
      class Roommates < Generic
        def form
          this = self
          section.field(property[:field_name]) do
            this.visibility(self)
            partial('roommates-list-form')
          end
        end

        def show
          this = self
          section.field(property[:field_name]) do
            this.visibility(self)
            pretty_value do
              bindings[:view].render(partial: 'roommates-list-preview', locals: { roommates: value })
            end
          end
        end
      end
    end
  end
end
