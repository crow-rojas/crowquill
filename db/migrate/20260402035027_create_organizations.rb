# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name,     null: false
      t.string :slug,     null: false, index: {unique: true}
      t.jsonb  :settings, null: false, default: {}

      t.timestamps
    end
  end
end
