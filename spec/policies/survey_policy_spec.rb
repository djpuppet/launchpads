# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SurveyPolicy do
  subject { described_class }

  let(:roles) { %i[host youth].freeze }
  let(:social_worker) { create(:user, :social_worker, :with_valid_parameters, :approved) }
  let(:user) { create(:user, roles.sample, :with_valid_parameters) }
  let(:survey) { create(:survey) }

  context 'when user is an social_worker' do
    context 'when survey user is not related to the social worker' do
      it { is_expected.to permit(social_worker, Survey, :index?) }
      it { is_expected.not_to permit(social_worker, survey, :fill?) }
      it { is_expected.not_to permit(social_worker, survey, :details?) }
      it { is_expected.not_to permit(social_worker, survey, :save?) }
    end

    context 'when social worker is unapproved' do
      let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }

      it 'raises an error' do
        expect { described_class.new(social_worker, Survey).index? }.to raise_error(Pundit::NotAuthorizedError)
        expect { described_class.new(social_worker, survey).fill? }.to raise_error(Pundit::NotAuthorizedError)
        expect { described_class.new(social_worker, survey).details? }.to raise_error(Pundit::NotAuthorizedError)
        expect { described_class.new(social_worker, survey).save? }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when survey user is related to the social worker' do
      let(:user) { create(:user, roles.sample, :with_valid_parameters, social_worker: social_worker) }
      let(:survey) { create(:survey, user: user) }

      it { is_expected.to permit(social_worker, Survey, :index?) }
      it { is_expected.to permit(social_worker, survey, :fill?) }
      it { is_expected.to permit(social_worker, survey, :details?) }
      it { is_expected.to permit(social_worker, survey, :save?) }
    end
  end

  context 'when user is not a social_worker' do
    it { is_expected.not_to permit(user, Survey, :index?) }
    it { is_expected.not_to permit(user, survey, :fill?) }
    it { is_expected.not_to permit(user, survey, :details?) }
    it { is_expected.not_to permit(user, survey, :save?) }
  end
end
