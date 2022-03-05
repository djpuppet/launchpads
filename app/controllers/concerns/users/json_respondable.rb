# frozen_string_literal: true

module Users
  module JsonRespondable
    extend ActiveSupport::Concern

    included do
      respond_to :json, :html

      def create
        super

        create_json_response if request.format.json?
      end

      private

      def create_json_response
        errors = resource.errors
        if errors.empty?
          response.body = flash.to_hash.to_json
          flash.clear
        else
          response.body = { errors: errors.full_messages }.to_json
        end
      end
    end
  end
end
