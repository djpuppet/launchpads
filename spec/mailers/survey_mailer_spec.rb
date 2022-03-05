# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SurveyMailer, type: :mailer do
  describe 'complete_survey' do
    let(:survey) { create(:survey) }
    let(:social_worker) { survey.user.social_worker }
    let(:mail) { described_class.complete_survey(social_worker, survey) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Youth temporarily denied using Launchpads')
      expect(mail.to).to eq([social_worker.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(CGI.escapeHTML(survey.user.username))
    end
  end

  describe 'new_survey_for_analysis' do
    let(:survey) { create(:survey) }
    let(:mail) { described_class.new_survey_for_analysis(survey) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Survey to fill up')
      expect(mail.to).to eq([ENV['ADMIN_EMAIL']])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include("#{ENV['APP_HOST']}/admin/survey/#{survey.id}")
    end
  end

  describe 'youth approved' do
    let(:survey) { create(:survey) }
    let(:mail) { described_class.youth_approved(survey.user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Youth approved to use the Launchpads app')
      expect(mail.to).to eq([survey.user.social_worker.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(CGI.escapeHTML(survey.user.username))
    end
  end
end
