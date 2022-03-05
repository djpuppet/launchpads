# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateConversationUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :conversation_users do |t|
      t.references :conversation, foreign_key: true
      t.references :user, foreign_key: true

      t.boolean :read, default: true
      t.boolean :ignored, default: false
      t.boolean :deleted, default: false
    end
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
