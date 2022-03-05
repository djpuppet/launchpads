# frozen_string_literal: true

module Admin
  class UserPolicy < ApplicationPolicy
    def select_type?
      user.admin?
    end

    def redirect_to_profile_form?
      user.admin?
    end
  end
end
