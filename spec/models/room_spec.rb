# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  subject(:described_obj) { described_class.new }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_inclusion_of(:city).in_array(Room::CITY_VALUES) }
    it { is_expected.to validate_presence_of(:move_in_date) }
    it { is_expected.to validate_presence_of(:duration_of_stay) }
    it { is_expected.to validate_presence_of(:about) }
    it { is_expected.to validate_inclusion_of(:furnished).in_array([true, false]) }
    it { is_expected.to validate_inclusion_of(:smoking).in_array(Room::SMOKING_VAPING_VALUES) }
    it { is_expected.to validate_inclusion_of(:vaping).in_array(Room::SMOKING_VAPING_VALUES) }
    it { is_expected.to validate_inclusion_of(:accept_children).in_array(Room::CHILDREN_VALUES) }
    it { is_expected.to validate_inclusion_of(:property_type).in_array(Room::PROPERTY_VALUES) }
    it { is_expected.to validate_inclusion_of(:room_type).in_array(Room::ROOM_VALUES) }

    it 'validates rent value > 0' do
      described_obj.rent = 0
      expect(described_obj).not_to be_valid
      expect(described_obj.errors).to be_key(:rent)
    end

    it 'validates rent value < 1500' do
      described_obj.rent = 1501
      expect(described_obj).not_to be_valid
      expect(described_obj.errors).to be_key(:rent)
    end

    it 'validates rent + utilities value < 1500' do
      described_obj.rent               = 1499
      described_obj.utilities          = 2
      expect(described_obj).not_to be_valid
      expect(described_obj.errors.keys).to include(:rent, :utilities)
    end

    it 'allows valid pet_friendly values' do
      described_obj.pet_friendly = Room::PET_FRIENDLY_VALUES.sample(2)
      described_obj.valid?
      expect(described_obj.errors).not_to be_of_kind(:pet_friendly)
    end

    it 'disallows invalid pet_friendly values' do
      described_obj.pet_friendly = Faker::Lorem.words(number: 2)
      described_obj.valid?
      expect(described_obj.errors).to be_of_kind(:pet_friendly)
    end

    it 'allows valid amenities values' do
      described_obj.amenities = Room::AMENITIES_VALUES.sample(2)
      described_obj.valid?
      expect(described_obj.errors).not_to be_of_kind(:amenities)
    end

    it 'disallows invalid amenities values' do
      described_obj.amenities = Faker::Lorem.words(number: 2)
      described_obj.valid?
      expect(described_obj.errors).to be_of_kind(:amenities)
    end

    it 'allows valid smoking types values' do
      described_obj.smoking_types = Room::SMOKING_TYPE_VALUES.sample(2)
      described_obj.valid?
      expect(described_obj.errors).not_to be_of_kind(:smoking_types)
    end

    it 'disallows invalid smoking types values' do
      described_obj.smoking_types = Faker::Lorem.words(number: 2)
      described_obj.valid?
      expect(described_obj.errors).to be_of_kind(:smoking_types)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'scopes' do
    let!(:rooms) do
      create_list(:room, 10, :with_valid_parameters) do |room, i|
        room.hidden   = i.odd?
        room.featured = i.even?
        room.user = create(:user, :host, :with_valid_parameters, :approved)
        room.save
      end
    end

    context 'with #visible' do
      it 'returns only visible rooms' do
        expect(described_class.visible.to_a).to be_none(&:hidden)
      end
    end

    context 'with #featured' do
      it 'returns only featured rooms' do
        expect(described_class.featured.to_a).to be_all(&:featured)
      end

      it 'returns only recent 3 rooms' do
        expect(described_class.featured.count).to eq(3)
      end

      context 'with less than 3 featured rooms available' do
        before do
          rooms[2..].each { |room| room.update(featured: false) }
        end

        it 'returns also most recent not featured rooms' do
          expect(described_class.featured.to_a).not_to be_all(&:featured)
        end

        it 'returns only recent 3 rooms' do
          expect(described_class.featured.count).to eq(3)
        end
      end
    end
  end

  describe '#hide!' do
    let(:room) { create(:room, :with_valid_parameters, hidden: false) }

    it 'changes the "hidden" attribute value' do
      expect { room.hide! }.to(change { room.reload.hidden })
    end
  end

  describe '#unhide!' do
    let(:room) { create(:room, :with_valid_parameters, hidden: true) }

    it 'changes the "hidden" attribute value' do
      expect { room.unhide! }.to(change { room.reload.hidden })
    end
  end

  describe '#owned_by?' do
    subject(:room) { create(:room, :with_valid_parameters, user: owner) }

    let(:owner) { create(:user, :host) }
    let(:user) { create(:user) }

    it { is_expected.to be_owned_by(owner) }
    it { is_expected.not_to be_owned_by(user) }
  end
end
