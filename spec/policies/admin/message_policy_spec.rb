# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::MessagePolicy do
  subject { described_class }

  let(:youth) { create(:user, :youth, :with_valid_parameters) }
  let(:admin) { create(:user, :admin, :with_valid_parameters) }
  let(:admin_message) { create(:message, user: admin) }
  let(:youth_message) { create(:message, user: admin) }

  context 'when the user is created by admin' do
    it { is_expected.to permit(admin, admin_message, :create?) }
  end

  context 'when the user is created by youth' do
    it { is_expected.not_to permit(youth, youth_message, :create?) }
  end
end
