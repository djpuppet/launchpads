# frozen_string_literal: true

class CreateSurveys < ActiveRecord::Migration[6.0]
  def change
    create_table :surveys do |t|
      t.references :user, foreign_key: true
      t.jsonb :properties, default: {}, null: false

      t.timestamps
    end
  end
end
