# frozen_string_literal: true

class AddUserToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :social_worker, references: :users, null: true

    add_foreign_key :users, :users, column: :social_worker_id
  end
end
