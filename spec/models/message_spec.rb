# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  subject(:described_obj) { described_class.new }

  describe 'association' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:conversation) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
  end
end
