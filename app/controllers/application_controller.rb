# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  include FormHelper
  include Pagy::Backend

  before_action :banned?
  before_action :authenticate
  before_action :authenticate_user!
  after_action :verify_authorized
  before_action :turbolinks_headers
  before_action :check_inbox_status

  def banned?
    return false unless current_user&.banned?

    sign_out current_user
    flash[:notice] = 'This account has been suspended by admin.'
    true
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def check_inbox_status
    @unread = if user_signed_in?
                current_user.conversations.where(conversation_users: { read: false })
              else
                []
              end
  end

  def paginate(scope, items)
    @pagy, records = pagy(scope, items: items, size: [1, 1, 1, 1])

    records
  end

  def turbolinks_headers
    turbolinks_redirect_url = flash[:turbolinks_redirect]
    flash.delete(:turbolinks_redirect)
    response.set_header('Turbolinks-Location', turbolinks_redirect_url) if turbolinks_redirect_url
  end

  private

  def user_not_authorized(exception)
    flash[:alert] = exception.query == :unapproved ? user_unapproved_alert : default_alert
    redirect_to '/'
  end

  def user_unapproved_alert
    {
      icon:    'media/images/icons/pen-icon.svg',
      heading: 'Your account is pending',
      message: 'You can edit and publish your profile anytime under the ' \
        "#{helpers.link_to('My Profile', profile_type_path)} tab."
    }
  end

  def default_alert
    'You are not authorized to perform this action.'
  end

  def set_raven_context
    Raven.user_context(id: current_user&.id)
    Raven.extra_context(params: request.filtered_parameters, url: request.url)
  end

  def authenticate
    return true if (ENV.keys & %w[BASIC_AUTH_USERNAME BASIC_AUTH_PASSWORD]).empty?

    authenticate_or_request_with_http_basic('Administration') do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username),
                                                  ::Digest::SHA256.hexdigest(ENV['BASIC_AUTH_USERNAME'])) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password),
                                                    ::Digest::SHA256.hexdigest(ENV['BASIC_AUTH_PASSWORD']))
    end
  end
end
