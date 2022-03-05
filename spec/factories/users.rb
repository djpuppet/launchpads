# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    password_confirmation { password }
    confirmed_at { DateTime.now }

    trait :approved do
      approved { true }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :youth do
      role { 'youth' }
      social_worker_id { create(:user, :social_worker, :with_valid_parameters).id }
      social_worker_unlisted { social_worker.blank? }
    end

    trait :host do
      role { 'host' }
    end

    trait :social_worker do
      role { 'social_worker' }
    end

    trait :admin do
      role { 'admin' }
    end

    trait :with_valid_parameters do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      username { Faker::Name.name }
      about { Faker::Lorem.sentence }
      gender { User::GENDER_VALUES.sample }
      other_gender { Faker::Gender.type if gender == 'other' }
      phone { Faker::PhoneNumber.subscriber_number(length: 10) }
      dob { Faker::Date.backward }
      children { Faker::Number.between(from: 1, to: 10) }
      lgbt_friendly { User::LGBT_FRIENDLY_VALUES.sample }
      pronouns { User::PRONOUNS_VALUES.sample }
      ethnicities { User::ETHNICITIES_VALUES.sample(2) }
      other_pronouns { User::PRONOUNS_VALUES.sample if pronouns == 'other' }
      transgender { User::TRANSGENDER_VALUES.sample }
      show_gender { %w[1 0].sample }
      show_ethnicity { %w[1 0].sample }
      show_pronouns { %w[1 0].sample }
      show_transgender { %w[1 0].sample }
      visible_messages_agreement { true }
      photos do
        [Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/assets/Photo.png'), 'image/png')]
      end
    end
  end
end
