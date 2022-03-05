# frozen_string_literal: true

class AddHiddenToRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :rooms, :hidden, :boolean, default: false
  end
end
