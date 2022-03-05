# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditingObject::Handlers::User, type: :service do
  describe 'update' do
    let(:user) { create(:user, :youth, :with_valid_parameters) }
    let(:args) { double }
    let(:email_message) { double }
    let(:survey_mail) { double }
    let(:described_obj) { described_class.new(args) }

    before do
      allow(args).to receive(:[]).with(:object).and_return(user)
      allow(ProfileMailer).to(
        receive(:approved_user)
          .with(satisfy { |value| value.id == user.id })
          .and_return(email_message)
      )
      allow(SurveyMailer).to(receive(:youth_approved)
                         .with(user)
                         .and_return(survey_mail))
      allow(email_message).to receive(:deliver_later)
      allow(survey_mail).to receive(:deliver_later)
    end

    context 'when the user has just been approved' do
      context 'when user has related social worker' do
        before do
          user.update(approved: true)
          described_obj.update
        end

        it 'sends the email message about the approved profile' do
          expect(SurveyMailer).to have_received(:youth_approved)
          expect(survey_mail).to have_received(:deliver_later)
          expect(ProfileMailer).to have_received(:approved_user)
          expect(email_message).to have_received(:deliver_later)
        end
      end

      context 'when user does not have related social worker' do
        before do
          user.update(approved: true, social_worker: nil, social_worker_unlisted: true)
          described_obj.update
        end

        it 'does not send a message to a social worker' do
          expect(SurveyMailer).not_to have_received(:youth_approved)
          expect(survey_mail).not_to have_received(:deliver_later)
          expect(ProfileMailer).to have_received(:approved_user)
          expect(email_message).to have_received(:deliver_later)
        end
      end
    end

    context 'when the user is not approved' do
      before do
        described_obj.update
      end

      it "doesn't send the email message about the approved profile" do
        expect(ProfileMailer).not_to have_received(:approved_user)
        expect(email_message).not_to have_received(:deliver_later)
        expect(SurveyMailer).not_to have_received(:youth_approved)
        expect(survey_mail).not_to have_received(:deliver_later)
      end
    end

    context 'when the user was previously approved' do
      before do
        user.update(approved: true)
        user.reload
        described_obj.update
      end

      it "doesn't send the email message about the approved profile" do
        expect(ProfileMailer).not_to have_received(:approved_user)
        expect(email_message).not_to have_received(:deliver_later)
        expect(SurveyMailer).not_to have_received(:youth_approved)
        expect(survey_mail).not_to have_received(:deliver_later)
      end
    end
  end
end
