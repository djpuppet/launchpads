# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UserPolicy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }

  context 'when user is an admin' do
    it { is_expected.to permit(admin, user, :dashboard?) }
    it { is_expected.to permit(admin, user, :index?) }
    it { is_expected.to permit(admin, user, :show?) }
    it { is_expected.to permit(admin, user, :edit?) }
    it { is_expected.to permit(admin, user, :update?) }
    it { is_expected.to permit(admin, user, :new?) }
    it { is_expected.to permit(admin, user, :create?) }
    it { is_expected.to permit(admin, user, :destroy?) }
    it { is_expected.to permit(admin, user, :select_type?) }
    it { is_expected.to permit(admin, user, :export?) }
    it { is_expected.to permit(admin, user, :redirect_to_profile_form?) }
  end

  context 'when user menages the other one' do
    it { is_expected.not_to permit(user, user, :dashboard?) }
    it { is_expected.not_to permit(user, user, :index?) }
    it { is_expected.not_to permit(user, user, :show?) }
    it { is_expected.not_to permit(user, user, :edit?) }
    it { is_expected.not_to permit(user, user, :update?) }
    it { is_expected.not_to permit(user, user, :new?) }
    it { is_expected.not_to permit(user, user, :create?) }
    it { is_expected.not_to permit(user, user, :destroy?) }
    it { is_expected.not_to permit(user, user, :select_type?) }
    it { is_expected.not_to permit(user, user, :export?) }
    it { is_expected.not_to permit(user, user, :redirect_to_profile_form?) }
  end
end
