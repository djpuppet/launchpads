# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Users::DeviseAbstractController < ApplicationController
  before_action :skip_authorization
  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:agreements_acceptance])
  end
end
# rubocop:enable Style/ClassAndModuleChildren
