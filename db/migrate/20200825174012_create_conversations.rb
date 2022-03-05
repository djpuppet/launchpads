# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateConversations < ActiveRecord::Migration[6.0]
  def change
    create_table :conversations
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
