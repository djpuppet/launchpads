# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    include Users::JsonRespondable

    protected

    # :reek:ControlParameter This is due to device dependency
    def after_sending_reset_password_instructions_path_for(resource_name)
      super unless resource_name == :user

      root_path
    end
  end
end
