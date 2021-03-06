# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include Users::JsonRespondable

    private

    def after_sign_up_path_for(_resource)
      root_path
    end

    def after_inactive_sign_up_path_for(_resource)
      root_path
    end
  end
end
