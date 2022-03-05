# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    conversation
    user
    content { Faker::Lorem.sentences(number: 10).join(' ') }
  end
end
