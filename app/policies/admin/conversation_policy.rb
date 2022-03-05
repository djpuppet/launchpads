# frozen_string_literal: true

module Admin
  class ConversationPolicy < ApplicationPolicy
    def ignore?
      user.admin?
    end

    def unignore?
      user.admin?
    end

    def find_or_create?
      user.admin?
    end

    def invite_social_worker?
      user.admin?
    end

    def edit?
      false
    end
  end
end
