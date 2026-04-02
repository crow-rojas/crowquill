# frozen_string_literal: true

class CreateSections < ActiveRecord::Migration[8.1]
  def change
    create_table :sections do |t|
      t.references :course, null: false, foreign_key: true
      t.references :tutor, null: false, foreign_key: {to_table: :users}
      t.string :name, null: false
      t.jsonb :schedule, null: false, default: {}
      t.integer :max_students, null: false, default: 12

      t.timestamps
    end
  end
end
