# frozen_string_literal: true

require Rails.root.join('lib/rails_admin/extensions/pundit_namespaced')
require Rails.root.join('app/services/auditing_object/auditing_adapter')
require 'nested_form/engine'
require 'nested_form/builder_mixin'

RailsAdmin.add_extension(:object_audit, AuditingObject, auditing: true)

RailsAdmin.config do |config|
  config.parent_controller = 'ApplicationController'
  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)
  config.authorize_with(:pundit_namespaced, :admin)
  config.audit_with(:object_audit)
  config.excluded_models = [Message]

  config.actions do
    dashboard
    index
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  RailsAdmin::Engine.routes.default_url_options = { host: ENV['APP_HOST'] }
end
