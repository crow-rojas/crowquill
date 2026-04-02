# frozen_string_literal: true

class CreateExerciseSets < ActiveRecord::Migration[8.1]
  def change
    create_table :exercise_sets do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :week_number, null: false
      t.text :content, null: false, default: ""
      t.jsonb :metadata, null: false, default: {}
      t.boolean :published, null: false, default: false

      t.timestamps
    end

    add_index :exercise_sets, %i[course_id week_number]
  end
end
