# frozen_string_literal: true

module AuditingObject
  module Handlers
    class Base
      def initialize(args)
        @args = args
      end

      def index; end

      def new; end

      def create; end

      def show; end

      def edit; end

      def update; end

      def delete; end
    end
  end
end
