# frozen_string_literal: true

puts "- Creating exercise sets..."

CrowquillSeeds.state[:courses_by_org].each_value do |courses_by_status|
  courses_by_status.each do |status_key, courses|
    courses.each do |course|
      CrowquillSeeds.seed_exercise_sets(
        course: course,
        period_status: status_key.to_s
      )
    end
  end
end
