# frozen_string_literal: true

FactoryBot.define do
  factory :conversation do
    users do
      [
        create(:user, :host, :with_valid_parameters, :approved),
        create(:user, :youth, :with_valid_parameters, :approved)
      ]
    end

    trait :with_messages do
      transient do
        messages_count { 5 }
      end

      after(:create) do |conversation, evaluator|
        create_list(:message, evaluator.messages_count, conversation: conversation)

        conversation.reload
      end
    end
  end
end
