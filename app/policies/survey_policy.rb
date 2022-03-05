# frozen_string_literal: true

class SurveyPolicy < ApplicationPolicy
  PERMITTED_PARAMS = %i[monthly_income silp_assesment_completed good_candidate can_develop_and_understand_budget
                        can_pay_rent can_manage_money pursuing_goals can_manage_schedule prepare_own_meals
                        cleans_after_self can_participate_in_shared_chores is_accessing_services
                        can_explain_drinking_strategies responsible_substance_use participate_in_house_agreements
                        can_manage_anger have_support aware_of_community_resources].freeze

  def index?
    user.social_worker? && user_approved?
  end

  def fill?
    user.social_worker? && user_approved? && record.user&.social_worker == user
  end

  def details?
    user.social_worker? && user_approved? && record.user&.social_worker == user
  end

  def save?
    user.social_worker? && user_approved? && record.user&.social_worker == user
  end

  private

  def user_approved?
    raise Pundit::NotAuthorizedError, query: :unapproved unless user.approved?

    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
