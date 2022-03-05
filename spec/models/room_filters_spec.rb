# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomFilters, type: :model do
  subject(:described_obj) { described_class.new(params) }

  let(:params) { {} }

  it { is_expected.to respond_to(:max_price, :max_price=) }
  it { is_expected.to respond_to(:duration_of_stay, :duration_of_stay=) }
  it { is_expected.to respond_to(:child_friendly, :child_friendly=) }
  it { is_expected.to respond_to(:pet_friendly, :pet_friendly=) }
  it { is_expected.to respond_to(:no_smoking, :no_smoking=) }

  context 'with default values' do
    it 'have @defaults_used flag' do
      expect(described_obj.defaults_used).to be_truthy
    end

    it 'returns max_price=1500' do
      expect(described_obj.max_price).to eq(1500)
    end

    it 'returns duration_of_stay=0' do
      expect(described_obj.duration_of_stay).to eq(0)
    end

    it 'returns child_friendly=false' do
      expect(described_obj.child_friendly).to be_falsey
    end

    it 'returns pet_friendly=false' do
      expect(described_obj.pet_friendly).to be_falsey
    end

    it 'returns no_smoking=false' do
      expect(described_obj.no_smoking).to be_falsey
    end
  end

  context 'with provided values' do
    let(:params) do
      {
        max_price:        1400,
        duration_of_stay: 10,
        child_friendly:   true,
        pet_friendly:     true,
        no_smoking:       true
      }
    end

    it 'does not have @defaults_used flag' do
      expect(described_obj.defaults_used).to be_falsey
    end

    it 'returns max_price=1400' do
      expect(described_obj.max_price).to eq(1400)
    end

    it 'returns duration_of_stay=10' do
      expect(described_obj.duration_of_stay).to eq(10)
    end

    it 'returns child_friendly=true' do
      expect(described_obj.child_friendly).to be_truthy
    end

    it 'returns pet_friendly=true' do
      expect(described_obj.pet_friendly).to be_truthy
    end

    it 'returns no_smoking=true' do
      expect(described_obj.no_smoking).to be_truthy
    end
  end
end
