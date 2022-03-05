# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    user { create(:user, :host, :with_valid_parameters) }

    trait :with_valid_parameters do
      title { Faker::Lorem.sentence }
      city { Room::CITY_VALUES.sample }
      other_city { Faker::Address.city if city == 'other' }
      move_in_date { Faker::Date.forward(days: 23) }
      duration_of_stay { Faker::Number.between(from: 1, to: 12) }
      rent { Faker::Number.between(from: 1, to: 1500) }
      property_type { Room::PROPERTY_VALUES.sample }
      room_type { Room::ROOM_VALUES.sample }
      furnished { %w[1 0].sample }
      about { Faker::Lorem.sentence }
      smoking { Room::SMOKING_VAPING_VALUES.sample }
      vaping { Room::SMOKING_VAPING_VALUES.sample }
      smoking_types { Room::SMOKING_TYPE_VALUES.sample(2) }
      pet_friendly { Room::PET_FRIENDLY_VALUES.sample(2) }
      accept_children { Room::CHILDREN_VALUES.sample }
      utilities { Faker::Number.between(from: 1, to: 1500 - rent) }
      amenities { Room::AMENITIES_VALUES.sample(2) }
      photos do
        [Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/assets/Photo.png'), 'image/png')]
      end
      featured { false }
    end
  end
end
