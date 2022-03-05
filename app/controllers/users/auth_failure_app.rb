# frozen_string_literal: true

module Users
  class AuthFailureApp < Devise::FailureApp
    protected

    def redirect_url
      flash[:turbolinks_redirect] = root_path
    end
  end
end
