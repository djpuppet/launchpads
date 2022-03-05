# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Survey, type: :model do
  subject(:described_obj) { described_class.new }

  describe 'association' do
    it { is_expected.to belong_to(:user) }
  end
end
