# frozen_string_literal: true

module Properties
  module Admin
    class EditField < Field
      protected

      def handler_method
        :form
      end
    end
  end
end
