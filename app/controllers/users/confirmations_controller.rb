# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    include Users::JsonRespondable

    def show
      super do |resource|
        errors = resource.errors
        unless errors.empty?
          flash[:confirmation_errors] = errors.full_messages
          redirect_to(root_path) && return
        end
      end
    end

    protected

    # :reek:ControlParameter This is due to device dependency
    def after_confirmation_path_for(resource_name, resource)
      super unless resource_name == :user

      root_path
    end

    # :reek:ControlParameter This is due to device dependency
    def after_resending_confirmation_instructions_path_for(resource_name)
      super unless resource_name == :user

      root_path
    end
  end
end
