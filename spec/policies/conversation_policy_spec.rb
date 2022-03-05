# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversationPolicy do
  subject { described_class }

  let(:users) do
    [
      create(:user, :youth, :with_valid_parameters),
      create(:user, :host, :with_valid_parameters)
    ]
  end
  let(:user) { create(:user, :youth, :with_valid_parameters, :approved) }
  let(:conversation) { create(:conversation, users: users) }

  context 'when user is not included to the conversation' do
    it { is_expected.not_to permit(user, conversation, :dashboard?) }
    it { is_expected.not_to permit(user, [conversation], :index?) }
    it { is_expected.not_to permit(user, conversation, :show?) }
    it { is_expected.not_to permit(user, conversation, :ignore?) }
    it { is_expected.not_to permit(user, conversation, :unignore?) }
    it { is_expected.not_to permit(user, conversation, :find_or_create?) }
    it { is_expected.not_to permit(user, conversation, :invite_social_worker?) }
    it { is_expected.not_to permit(user, conversation, :report?) }
  end

  context 'when user is included to the conversation but not approved' do
    it { is_expected.not_to permit(users.sample, conversation, :dashboard?) }

    # rubocop:disable RSpec/ExampleLength
    it 'raises an error' do
      expect { described_class.new(users.sample, conversation).show? }.to raise_error(Pundit::NotAuthorizedError)
      expect { described_class.new(users.sample, conversation).ignore? }.to raise_error(Pundit::NotAuthorizedError)
      expect { described_class.new(users.sample, conversation).unignore? }.to raise_error(Pundit::NotAuthorizedError)
      expect { described_class.new(users.sample, conversation).report? }.to raise_error(Pundit::NotAuthorizedError)
      expect { described_class.new(users.sample, conversation).find_or_create? }
        .to raise_error(Pundit::NotAuthorizedError)
      expect { described_class.new(users.sample, [conversation]).index? }
        .to raise_error(Pundit::NotAuthorizedError)
      expect { described_class.new(users.sample, conversation).invite_social_worker? }
        .to raise_error(Pundit::NotAuthorizedError)
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context 'when user is included to the conversation and is approved' do
    let(:users) do
      [
        create(:user, :youth, :with_valid_parameters, :approved),
        create(:user, :host, :with_valid_parameters, :approved)
      ]
    end

    it { is_expected.not_to permit(users.sample, conversation, :dashboard?) }
    it { is_expected.to permit(users.sample, [conversation], :index?) }
    it { is_expected.to permit(users.sample, conversation, :show?) }
    it { is_expected.to permit(users.sample, conversation, :ignore?) }
    it { is_expected.to permit(users.sample, conversation, :unignore?) }
    it { is_expected.to permit(users.sample, conversation, :find_or_create?) }
    it { is_expected.to permit(users.sample, conversation, :invite_social_worker?) }
    it { is_expected.to permit(users.sample, conversation, :report?) }
  end
end
