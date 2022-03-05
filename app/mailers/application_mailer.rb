# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV['NOTIFICATIONS_EMAIL']
  layout 'mailer'

  def fetch_admins_emails
    ENV['ADMIN_EMAIL'].split(';').map(&:strip)
  end
end
