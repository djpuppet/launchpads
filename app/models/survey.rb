# frozen_string_literal: true

class Survey < ApplicationRecord
  DETAILS_VALUES = ['Yes', 'Skill to be developed', 'Unsure'].freeze
  MONTHLY_INCOME_VALUES = ['$0', '$1 - 499', '$500 - $999', '$1000 - $1499', '$1500 - $2000', '$2000+'].freeze
  INITIAL_CONTEXTS = %i[initial create update].freeze
  DETAILS_CONTEXTS = %i[details create update].freeze
  INITIAL_ATTRIBUTES = %i[monthly_income silp_assesment_completed good_candidate].freeze

  belongs_to :user

  include SurveyAdmin
  extend WithProperties

  # initial
  property :monthly_income, :dropdown, options: { values: MONTHLY_INCOME_VALUES }
  property :silp_assesment_completed, :boolean
  property :good_candidate, :boolean

  # details
  property :can_develop_and_understand_budget, :dropdown, options: { values: DETAILS_VALUES }
  property :can_pay_rent, :dropdown, options: { values: DETAILS_VALUES }
  property :can_manage_money, :dropdown, options: { values: DETAILS_VALUES }
  property :pursuing_goals, :dropdown, options: { values: DETAILS_VALUES }
  property :can_manage_schedule, :dropdown, options: { values: DETAILS_VALUES }
  property :prepare_own_meals, :dropdown, options: { values: DETAILS_VALUES }
  property :cleans_after_self, :dropdown, options: { values: DETAILS_VALUES }
  property :can_participate_in_shared_chores, :dropdown, options: { values: DETAILS_VALUES }
  property :is_accessing_services, :dropdown, options: { values: DETAILS_VALUES }
  property :can_explain_drinking_strategies, :dropdown, options: { values: DETAILS_VALUES }
  property :responsible_substance_use, :dropdown, options: { values: DETAILS_VALUES }
  property :participate_in_house_agreements, :dropdown, options: { values: DETAILS_VALUES }
  property :can_manage_anger, :dropdown, options: { values: DETAILS_VALUES }
  property :have_support, :dropdown, options: { values: DETAILS_VALUES }
  property :aware_of_community_resources, :dropdown, options: { values: DETAILS_VALUES }

  validates :monthly_income, inclusion: { in: MONTHLY_INCOME_VALUES }, on: INITIAL_CONTEXTS
  validates :silp_assesment_completed, inclusion: { in: [true, false] }, on: INITIAL_CONTEXTS
  validates :good_candidate, inclusion: { in: [true, false] }, on: INITIAL_CONTEXTS

  SurveyPolicy::PERMITTED_PARAMS.each do |attribute|
    next if INITIAL_ATTRIBUTES.include?(attribute)

    property attribute, :dropdown
    validates attribute,
              presence: true,
              if:       -> { details_required? && persisted? },
              on:       DETAILS_CONTEXTS
    validates attribute,
              inclusion: { in: DETAILS_VALUES },
              if:        -> { send(attribute).present? && details_required? && persisted? },
              on:        DETAILS_CONTEXTS
  end

  def details_required?
    !(monthly_income.present? && good_candidate && silp_assesment_completed)
  end
end
