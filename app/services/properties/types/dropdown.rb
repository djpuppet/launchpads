# frozen_string_literal: true

module Properties
  module Types
    class Dropdown < Generic
      # :reek:FeatureEnvy
      def serialize(value)
        return value unless property.dig(:options, :multiple)

        Array(value).select(&:present?)
      end

      # :reek:FeatureEnvy
      def deserialize(value)
        return Array(value) if property.dig(:options, :multiple)

        value
      end
    end
  end
end
