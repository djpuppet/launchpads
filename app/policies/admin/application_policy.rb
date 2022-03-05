# frozen_string_literal: true

module Admin
  class ApplicationPolicy < ApplicationPolicy
    def index?
      user.admin?
    end

    def show?
      user.admin?
    end

    def create?
      user.admin?
    end

    def new?
      user.admin?
    end

    def update?
      user.admin?
    end

    def edit?
      user.admin?
    end

    def destroy?
      user.admin?
    end

    def show_in_app?
      false
    end

    def export?
      user.admin?
    end
  end
end
