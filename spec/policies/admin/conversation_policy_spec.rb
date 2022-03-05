# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ConversationPolicy do
  subject { described_class }

  let(:users) { [create(:user, :youth, :with_valid_parameters), create(:user, :host, :with_valid_parameters)] }
  let(:admin) { create(:user, :admin) }
  let(:conversation) { create(:conversation, users: users) }

  context 'when user is not included to the conversation' do
    it { is_expected.to permit(admin, conversation, :dashboard?) }
    it { is_expected.to permit(admin, [conversation], :index?) }
    it { is_expected.to permit(admin, conversation, :show?) }
    it { is_expected.to permit(admin, conversation, :ignore?) }
    it { is_expected.to permit(admin, conversation, :unignore?) }
    it { is_expected.to permit(admin, conversation, :find_or_create?) }
    it { is_expected.to permit(admin, conversation, :invite_social_worker?) }
    it { is_expected.to permit(admin, conversation, :export?) }
    it { is_expected.not_to permit(admin, conversation, :edit?) }
  end

  context 'when user is included to the conversation' do
    it { is_expected.not_to permit(users.sample, conversation, :dashboard?) }
    it { is_expected.not_to permit(users.sample, [conversation], :index?) }
    it { is_expected.not_to permit(users.sample, conversation, :show?) }
    it { is_expected.not_to permit(users.sample, conversation, :ignore?) }
    it { is_expected.not_to permit(users.sample, conversation, :unignore?) }
    it { is_expected.not_to permit(users.sample, conversation, :find_or_create?) }
    it { is_expected.not_to permit(users.sample, conversation, :invite_social_worker?) }
    it { is_expected.not_to permit(users.sample, conversation, :export?) }
    it { is_expected.not_to permit(users.sample, conversation, :edit?) }
  end
end
