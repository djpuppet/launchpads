# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::RoomPolicy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user, User::PROFILES.keys.sample) }
  let(:room) { create(:room, :with_valid_parameters) }

  context 'when user is an admin' do
    it { is_expected.to permit(admin, room, :dashboard?) }
    it { is_expected.to permit(admin, room, :index?) }
    it { is_expected.to permit(admin, room, :show?) }
    it { is_expected.to permit(admin, room, :edit?) }
    it { is_expected.to permit(admin, room, :update?) }
    it { is_expected.to permit(admin, room, :new?) }
    it { is_expected.to permit(admin, room, :create?) }
    it { is_expected.to permit(admin, room, :export?) }
    it { is_expected.to permit(admin, room, :destroy?) }
  end

  context 'when user is not an admin' do
    it { is_expected.not_to permit(user, room, :dashboard?) }
    it { is_expected.not_to permit(user, room, :index?) }
    it { is_expected.not_to permit(user, room, :show?) }
    it { is_expected.not_to permit(user, room, :edit?) }
    it { is_expected.not_to permit(user, room, :update?) }
    it { is_expected.not_to permit(user, room, :new?) }
    it { is_expected.not_to permit(user, room, :create?) }
    it { is_expected.not_to permit(user, room, :export?) }
    it { is_expected.not_to permit(user, room, :destroy?) }
  end
end
