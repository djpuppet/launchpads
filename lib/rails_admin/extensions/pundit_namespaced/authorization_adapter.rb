# frozen_string_literal: true

module RailsAdmin
  module Extensions
    module PunditNamespaced
      class AuthorizationAdapter < RailsAdmin::Extensions::Pundit::AuthorizationAdapter
        def initialize(controller, namespace)
          super(controller)
          @namespace = namespace
        end

        def query(_action, abstract_model)
          @controller.send(:policy_scope, [@namespace, abstract_model.model.all])
        rescue ::Pundit::NotDefinedError
          super
        end

        private

        def policy(record)
          @controller.send(:policy, [@namespace, record])
        rescue ::Pundit::NotDefinedError
          super(record)
        end
      end
    end
  end
end
