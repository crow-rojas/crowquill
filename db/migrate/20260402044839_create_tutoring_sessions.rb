# frozen_string_literal: true

class CreateTutoringSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :tutoring_sessions do |t|
      t.references :section, null: false, foreign_key: true
      t.date :date, null: false
      t.string :status, null: false, default: "scheduled"

      t.timestamps
    end
  end
end
