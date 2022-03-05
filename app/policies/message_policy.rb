# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  def create?
    return false unless user_approved?

    record.user == user
  end

  private

  def user_approved?
    raise Pundit::NotAuthorizedError, query: :unapproved unless user.approved?

    true
  end
end
