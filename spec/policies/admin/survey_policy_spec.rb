# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SurveyPolicy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:survey) { create(:survey) }

  context 'when user is an admin' do
    it { is_expected.to permit(admin, survey, :dashboard?) }
    it { is_expected.to permit(admin, survey, :index?) }
    it { is_expected.to permit(admin, survey, :show?) }
    it { is_expected.not_to permit(admin, survey, :edit?) }
    it { is_expected.not_to permit(admin, survey, :update?) }
    it { is_expected.not_to permit(admin, survey, :new?) }
    it { is_expected.not_to permit(admin, survey, :create?) }
    it { is_expected.to permit(admin, survey, :export?) }
    it { is_expected.to permit(admin, survey, :destroy?) }
    it { is_expected.not_to permit(admin, survey, :fill?) }
    it { is_expected.not_to permit(admin, survey, :details?) }
    it { is_expected.not_to permit(admin, survey, :save?) }
  end
end
