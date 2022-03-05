# frozen_string_literal: true

FactoryBot.define do
  factory :survey do
    association :user, :youth, :with_valid_parameters
    monthly_income { Survey::MONTHLY_INCOME_VALUES.sample }
    silp_assesment_completed { [true, false].sample }
    good_candidate { [true, false].sample }

    trait :with_details do
      can_develop_and_understand_budget { Survey::DETAILS_VALUES.sample }
      can_pay_rent { Survey::DETAILS_VALUES.sample }
      can_manage_money { Survey::DETAILS_VALUES.sample }
      pursuing_goals { Survey::DETAILS_VALUES.sample }
      can_manage_schedule { Survey::DETAILS_VALUES.sample }
      prepare_own_meals { Survey::DETAILS_VALUES.sample }
      cleans_after_self { Survey::DETAILS_VALUES.sample }
      can_participate_in_shared_chores { Survey::DETAILS_VALUES.sample }
      is_accessing_services { Survey::DETAILS_VALUES.sample }
      can_explain_drinking_strategies { Survey::DETAILS_VALUES.sample }
      responsible_substance_use { Survey::DETAILS_VALUES.sample }
      participate_in_house_agreements { Survey::DETAILS_VALUES.sample }
      can_manage_anger { Survey::DETAILS_VALUES.sample }
      have_support { Survey::DETAILS_VALUES.sample }
      aware_of_community_resources { Survey::DETAILS_VALUES.sample }
    end
  end
end
