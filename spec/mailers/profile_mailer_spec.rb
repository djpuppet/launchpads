# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileMailer, type: :mailer do
  let(:youth) { create(:user, :youth, :with_valid_parameters, approved: true) }

  describe 'complete_profile' do
    let(:mail) { described_class.complete_profile(youth) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Thanks for creating your Launchpads profile! Next steps')
      expect(mail.to).to eq([youth.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(youth.name.to_s)
    end
  end

  describe 'approved_user' do
    context 'when user is a youth' do
      let(:mail) { described_class.approved_user(youth) }

      it 'renders the headers' do
        expect(mail.subject).to eq('Your Launchpads account has been approved!')
        expect(mail.to).to eq([youth.email])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match(youth.first_name.to_s)
        expect(mail.body.encoded).to match(root_url.to_s)
      end
    end

    context 'when user is a host' do
      let(:host) { create(:user, :host, :with_valid_parameters) }
      let(:mail) { described_class.approved_user(host) }

      it 'renders the headers' do
        expect(mail.subject).to eq('Your Launchpads account has been approved!')
        expect(mail.to).to eq([host.email])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match(host.first_name.to_s)
      end
    end

    context 'when user is a social_worker' do
      let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }
      let(:mail) { described_class.approved_user(social_worker) }

      it 'renders the headers' do
        expect(mail.subject).to eq('Your Launchpads account has been approved!')
        expect(mail.to).to eq([social_worker.email])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match(social_worker.first_name.to_s)
      end
    end
  end

  describe 'complete_profile_to_survey' do
    let(:youth) { create(:user, :youth, :with_valid_parameters) }
    let(:social_worker) { youth.social_worker }
    let(:mail) { described_class.complete_profile_to_survey(youth, social_worker) }

    it 'renders the headers' do
      expect(mail.subject).to eq('New survey to complete')
      expect(mail.to).to eq([social_worker.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(social_worker.first_name.to_s)
      expect(mail.body.encoded).to match(fill_surveys_url(youth))
      expect(mail.body.encoded).to match(youth.name.to_s)
    end
  end

  describe 'complete_profile_to_approval' do
    let(:mail) { described_class.complete_profile_to_approval(youth) }

    it 'renders the headers' do
      expect(mail.subject).to eq("New #{youth.role} to approve")
      expect(mail.to).to eq([ENV['ADMIN_EMAIL']])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("#{ENV['APP_HOST']}/admin/user/#{youth.id}/edit")
    end
  end
end
