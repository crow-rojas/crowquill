# frozen_string_literal: true

class AddYearAndSemesterToAcademicPeriods < ActiveRecord::Migration[8.1]
  def change
    add_column :academic_periods, :year, :integer, null: false
    add_column :academic_periods, :semester, :integer, null: false
    change_column_null :academic_periods, :name, true

    add_index :academic_periods, %i[organization_id year semester], unique: true,
      name: "index_academic_periods_on_org_year_semester"
  end
end
