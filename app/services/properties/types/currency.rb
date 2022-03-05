# frozen_string_literal: true

module Properties
  module Types
    class Currency < Generic
      # :reek:UtilityFunction
      def serialize(value)
        value.to_f
      end

      # :reek:UtilityFunction
      def deserialize(value)
        value.to_f
      end
    end
  end
end
