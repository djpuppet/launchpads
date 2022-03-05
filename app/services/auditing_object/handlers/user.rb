# frozen_string_literal: true

module AuditingObject
  module Handlers
    class User < Base
      def update
        user = ::User.new(@args[:object].attributes)
        notify(user) if should_send_approval_notification?
      end

      private

      def should_send_approval_notification?
        @args[:object].approved_previously_changed? && @args[:object].approved?
      end

      def notify(user)
        return if user.admin?

        SurveyMailer.youth_approved(user).deliver_later if user.youth? && user.social_worker.present?
        ProfileMailer.approved_user(user).deliver_later
      end
    end
  end
end
