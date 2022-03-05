# frozen_string_literal: true

class AddFeaturedToRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :rooms, :featured, :boolean, default: false
  end
end
