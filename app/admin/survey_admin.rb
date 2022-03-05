# :nocov:
# frozen_string_literal: true

module SurveyAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        field :id
        field :user do
          pretty_value do
            ApplicationAdmin.related_user_pretty_value(bindings)
          end
        end
        field :created_at
      end

      show do
        field :id
        field :user do
          pretty_value do
            ApplicationAdmin.related_user_pretty_value(bindings)
          end
        end
        ApplicationAdmin.properties_for(Survey, self)
        field :created_at
      end
    end
  end
end
