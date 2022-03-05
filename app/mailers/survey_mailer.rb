# frozen_string_literal: true

class SurveyMailer < ApplicationMailer
  def complete_survey(social_worker, survey)
    @survey = survey
    @social_worker = social_worker
    mail(to: social_worker.email, subject: 'Youth temporarily denied using Launchpads')
  end

  def youth_approved(youth)
    social_worker = youth.social_worker
    @youth = youth
    mail(to: social_worker.email, subject: 'Youth approved to use the Launchpads app')
  end

  def new_survey_for_analysis(survey)
    @survey = survey
    @url = admin_show_url
    admin = fetch_admins_emails
    mail(to: admin, subject: 'Survey to fill up')
  end

  private

  def admin_show_url
    RailsAdmin::Engine.routes.url_helpers.show_url('survey', @survey)
  end
end
