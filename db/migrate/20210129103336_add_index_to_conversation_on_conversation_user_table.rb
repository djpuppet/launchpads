# frozen_string_literal: true

class AddIndexToConversationOnConversationUserTable < ActiveRecord::Migration[6.1]
  def change
    add_index :conversation_users, %i[user_id conversation_id], unique: true
  end
end
