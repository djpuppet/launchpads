# frozen_string_literal: true

module Properties
  module Admin
    class ShowField < Field
      protected

      def handler_method
        :show
      end
    end
  end
end
