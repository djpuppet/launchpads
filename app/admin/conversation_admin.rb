# :nocov:
# frozen_string_literal: true

module ConversationAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        field :id
        field :users
        field :created_at
        field :updated_at
        field :messages do
          pretty_value do
            bindings[:object].messages.count
          end
        end
      end

      show do
        field :id
        field :users
        field :created_at
        field :updated_at
        field :messages do
          pretty_value do
            bindings[:view].render partial: 'messages-preview', locals: { messages: value }
          end
        end
      end
    end
  end
end
