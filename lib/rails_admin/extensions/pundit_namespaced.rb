# frozen_string_literal: true

require Rails.root.join(__dir__, 'pundit_namespaced/authorization_adapter')

RailsAdmin.add_extension(:pundit_namespaced, RailsAdmin::Extensions::PunditNamespaced, authorization: true)
