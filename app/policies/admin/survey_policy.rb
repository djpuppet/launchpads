# frozen_string_literal: true

module Admin
  class SurveyPolicy < ApplicationPolicy
    def new?
      false
    end

    def create?
      false
    end

    def edit?
      false
    end

    def update?
      false
    end

    def fill?
      false
    end

    def save?
      false
    end

    def details?
      false
    end
  end
end
