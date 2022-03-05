# frozen_string_literal: true

module Properties
  module Types
    class Boolean < Generic
      # :reek:UtilityFunction
      def serialize(value)
        if value == ''
          nil
        else
          ActiveRecord::Type::Boolean::FALSE_VALUES.exclude?(value)
        end
      end
    end
  end
end
