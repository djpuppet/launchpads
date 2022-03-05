# frozen_string_literal: true

class AddPropertiesToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :properties, :jsonb, null: false, default: {}
  end
end
