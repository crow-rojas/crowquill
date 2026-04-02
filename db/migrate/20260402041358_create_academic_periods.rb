# frozen_string_literal: true

class CreateAcademicPeriods < ActiveRecord::Migration[8.1]
  def change
    create_table :academic_periods do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false, default: "draft"

      t.timestamps
    end
  end
end
