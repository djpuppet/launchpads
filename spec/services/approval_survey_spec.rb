# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApprovalSurvey do
  describe 'self.call' do
    let(:mail) { double }

    before do
      allow(ProfileMailer).to receive(:approved_user).and_return(mail)
      allow(mail).to receive(:deliver_later)
    end

    context 'when survey is not persisted' do
      context 'when all attributes for the survey were given' do
        let(:survey) { build(:survey) }

        it 'returns all attributes as a truth' do
          result = described_class.call(survey)
          expect(result.success).to be_truthy
          expect(result.valid).to be_truthy
        end
      end

      context "when haven't got some attribute" do
        let(:survey) { Survey.new }

        it 'returns all attributes as a false' do
          result = described_class.call(survey)
          expect(result.success).to be_falsey
          expect(result.valid).to be_falsey
        end
      end
    end

    # rubocop:disable RSpec/PredicateMatcher
    context 'when survey is persisted' do
      context 'when all initial attributes are positive' do
        let(:survey) { create(:survey, good_candidate: true, silp_assesment_completed: true) }
        let(:result) { described_class.call(survey) }

        it 'returns all attributes as a truth' do
          expect(result.success).to be_truthy
          expect(result.valid).to be_truthy
        end

        it 'approves the user' do
          result
          expect(survey.reload.user.approved?).to be_truthy
        end

        it 'sends the email notifications to the user' do
          result
          expect(ProfileMailer).to have_received(:approved_user)
          expect(mail).to have_received(:deliver_later)
        end
      end

      context "when one initial attribute is negative and didn't get details attributes" do
        let(:survey) { create(:survey, good_candidate: '0') }
        let(:result) { described_class.call(survey) }

        it 'returns success as a false and valid as a truth' do
          expect(result.success).to be_falsey
          expect(result.valid).to be_truthy
        end

        it "doesn't approve the user" do
          result
          expect(survey.reload.user.approved?).to be_falsey
        end

        it 'does not send the email notifications to the user' do
          result
          expect(ProfileMailer).not_to have_received(:approved_user)
          expect(mail).not_to have_received(:deliver_later)
        end
      end

      context 'when one initial attribute is negative and it got details attributes' do
        let(:survey) { create(:survey, :with_details, good_candidate: '0') }
        let(:result) { described_class.call(survey) }

        it 'returns all attributes as a truth' do
          expect(result.success).to be_truthy
          expect(result.valid).to be_truthy
        end

        it "doesn't approve the user" do
          result
          expect(survey.reload.user.approved?).to be_falsey
        end

        it 'does not send the email notifications to the user' do
          result
          expect(ProfileMailer).not_to have_received(:approved_user)
          expect(mail).not_to have_received(:deliver_later)
        end
      end
    end
    # rubocop:enable RSpec/PredicateMatcher
  end
end
