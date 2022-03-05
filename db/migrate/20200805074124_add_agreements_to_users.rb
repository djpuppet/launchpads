# frozen_string_literal: true

class AddAgreementsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :agreements_acceptance, :boolean
  end
end
