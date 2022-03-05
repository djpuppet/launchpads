# frozen_string_literal: true

class ProfileMailer < ApplicationMailer
  def complete_profile(user)
    @user = user
    mail(to: @user.email, subject: 'Thanks for creating your Launchpads profile! Next steps')
  end

  def approved_user(user)
    @user = user
    mail(to: @user.email, subject: 'Your Launchpads account has been approved!')
  end

  def complete_profile_to_survey(youth, social_worker)
    @youth = youth
    @social_worker = social_worker
    mail(to: @social_worker.email, subject: 'New survey to complete')
  end

  def complete_profile_to_approval(user)
    @user = user
    @url = admin_edit_url
    admin = fetch_admins_emails
    mail(to: admin, subject: "New #{@user.role} to approve")
  end

  private

  def admin_edit_url
    RailsAdmin::Engine.routes.url_helpers.edit_url('user', @user)
  end
end
