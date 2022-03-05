# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  PERMITTED_UPDATE_PARAMS = [
    :email, :first_name, :last_name, :username, :social_worker_unlisted, :gender, :phone, :dob, :social_worker_id,
    :other_benefits, :other_gender, :transgender, :pronouns, :other_pronouns, :other_ethnicity, :how_gender,
    :show_pronouns, :show_transgender, :show_ethnicity, :about, :education, :school, :work, :show_gender,
    :lgbt_friendly, :children, :visible_messages_agreement, :language, { benefits: [], ethnicities: [], photos: [] }
  ].freeze

  def show?
    user.present?
  end

  def preview?
    user.present? && %w[host youth].include?(user.role)
  end

  def edit?
    user == record && user.confirmed? && !user.banned?
  end

  def update?
    user == record && user.confirmed? && !user.banned?
  end

  def update_password?
    user == record
  end

  def validate?
    user == record && user.confirmed? && !user.banned?
  end

  def select_type?
    user == record && user.confirmed? && !user.banned?
  end

  def redirect_to_profile_form?
    user == record && user.confirmed? && !user.banned?
  end

  def update_params(role)
    PERMITTED_UPDATE_PARAMS - other_role_properties(role)
  end

  class Scope < Scope
    def resolve
      fetch_users_collection
    end

    private

    def user_ids_within_conversation
      user_id          = user.id
      conversation_ids = ConversationUser.where(user_id: user_id).pluck(:conversation_id)
      ConversationUser.where(conversation_id: conversation_ids).where.not(user_id: user_id).pluck(:user_id)
    end

    def fetch_users_collection
      if user.social_worker?
        scope.for_social_worker(user)
      elsif user.host?
        users_for_host
      else
        scope.where(id: user.id).or(scope.with_role(:host).approved)
      end
    end

    def users_for_host
      scope.where(id: user_ids_within_conversation + [user.id]).or(scope.with_role(:host).approved)
    end
  end

  private

  # :reek:UtilityFunction
  def other_role_properties(role)
    User.registered_properties.values.reject { |prop| prop[:roles].include?(role) }.pluck(:field_name)
  end
end
