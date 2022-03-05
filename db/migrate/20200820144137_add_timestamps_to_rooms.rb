# frozen_string_literal: true

class AddTimestampsToRooms < ActiveRecord::Migration[6.0]
  def change
    change_table(:rooms) do |t|
      t.timestamps(default: -> { 'CURRENT_TIMESTAMP' })
    end
  end
end
