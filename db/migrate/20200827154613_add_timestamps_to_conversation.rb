# frozen_string_literal: true

class AddTimestampsToConversation < ActiveRecord::Migration[6.0]
  def change
    change_table(:conversations) do |t|
      t.timestamps(default: -> { 'CURRENT_TIMESTAMP' })
    end
  end
end
