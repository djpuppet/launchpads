# frozen_string_literal: true

class ConversationPolicy < ApplicationPolicy
  def index?
    return false unless user_approved?

    record.all? { |item| item.users.include?(user) }
  end

  def show?
    return false unless user_approved?

    record.users.include?(user)
  end

  def ignore?
    return false unless user_approved?

    record.users.include?(user)
  end

  def unignore?
    return false unless user_approved?

    record.users.include?(user)
  end

  def find_or_create?
    return false unless user_approved?

    record.users.include?(user)
  end

  def invite_social_worker?
    return false unless user_approved?

    record.users.include?(user)
  end

  def report?
    return false unless user_approved?

    record.users.include?(user)
  end

  private

  def user_approved?
    raise Pundit::NotAuthorizedError, query: :unapproved unless user.approved?

    true
  end

  class Scope < Scope
    def resolve
      scope.joins(:conversation_users).where(conversation_users: { user_id: user.id })
    end
  end
end
