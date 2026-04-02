# frozen_string_literal: true

puts "- Creating enrollments, tutoring sessions, and attendance..."

CrowquillSeeds.state[:sections_by_org].each do |slug, grouped_sections|
  students_pool = CrowquillSeeds.state[:org_students].fetch(slug)

  grouped_sections.each do |status_key, sections|
    occupancy_range = case status_key
    when :archived
      0.45..0.80
    when :active
      0.65..1.00
    else
      0.0..0.45
    end

    sections.each do |section|
      CrowquillSeeds.seed_enrollments(
        section: section,
        students: students_pool,
        occupancy_range: occupancy_range,
        allow_withdrawals: status_key != :draft
      )

      CrowquillSeeds.seed_tutoring_sessions(
        section: section,
        period: CrowquillSeeds.state[:periods_by_org].fetch(slug).fetch(status_key),
        period_status: status_key.to_s
      )
    end
  end
end
