# frozen_string_literal: true

class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :section, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "active"
      t.datetime :commitment_accepted_at

      t.timestamps
    end

    add_index :enrollments, %i[section_id user_id], unique: true
  end
end
