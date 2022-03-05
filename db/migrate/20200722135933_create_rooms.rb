# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateRooms < ActiveRecord::Migration[6.0]
  def change
    create_table :rooms do |t|
      t.jsonb :properties, default: {}, null: false
      t.references :user, foreign_key: true
    end
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
