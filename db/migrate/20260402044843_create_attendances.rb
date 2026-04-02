# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :tutoring_session, null: false, foreign_key: true
      t.references :enrollment, null: false, foreign_key: true
      t.string :status, null: false, default: "absent"
      t.text :notes

      t.timestamps
    end

    add_index :attendances, %i[tutoring_session_id enrollment_id], unique: true
  end
end
