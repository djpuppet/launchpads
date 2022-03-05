# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagePolicy do
  subject { described_class }

  let(:youth) { create(:user, :youth, :with_valid_parameters) }
  let(:host) { create(:user, :host, :with_valid_parameters, :approved) }
  let(:message) { create(:message, user: youth) }

  context 'when the user is not an author of the message' do
    it { is_expected.not_to permit(host, message, :create?) }
  end

  context 'when the user is an author of the message and is not approved' do
    it 'raises an error' do
      expect { described_class.new(youth, message).create? }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'when the user is an author of the message and is approved' do
    let(:youth) { create(:user, :youth, :with_valid_parameters, :approved) }

    it { is_expected.to permit(youth, message, :create?) }
  end
end
