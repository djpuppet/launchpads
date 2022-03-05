# frozen_string_literal: true

module Properties
  module Types
    class Date < Generic
      DATE_FORMAT = '%m-%d-%Y'

      # :reek:UtilityFunction
      def serialize(value)
        prepared_value = ensure_date_object(value)

        prepared_value&.to_s
      end

      # :reek:UtilityFunction
      def deserialize(value)
        value&.to_date
      rescue ArgumentError
        nil
      end

      private

      def ensure_date_object(value)
        if value.is_a?(String)
          parse_date(value)
        elsif value.respond_to?(:to_date)
          value.to_date
        end
      end

      def parse_date(value)
        return if value.nil?

        ::Date.strptime(value, DATE_FORMAT)
      rescue ArgumentError
        value.to_s.to_date
      end
    end
  end
end
