# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # POST /resource/sign_in
    def create
      if request.format.json?
        user = warden.authenticate(auth_options)

        return invalid_login unless user
      end

      super
    end

    private

    def invalid_login
      render json: { error: find_message(:invalid) }, status: :unauthorized
    end

    protected

    def after_sign_in_path_for(resource)
      if resource.is_a?(User)
        return profile_form_path unless resource.role?
        return manage_banned_user(resource) if resource.banned_youth?
        return surveys_path if resource.social_worker?
        return rails_admin_path if resource.admin?
        return rooms_path if resource.host?
      end

      super
    end

    def manage_banned_user(user)
      sign_out user
      flash[:notice] = 'This account has been suspended by admin.'
      root_path
    end
  end
end
