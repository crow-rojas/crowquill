# frozen_string_literal: true

puts "- Creating academic periods, courses, and sections..."

period_templates = CrowquillSeeds.semester_windows

CrowquillSeeds.state[:organizations].each do |slug, organization|
  CrowquillSeeds.state[:periods_by_org][slug] = period_templates.transform_values do |template|
    CrowquillSeeds.seed_period(
      organization: organization,
      name: template[:name],
      start_date: template[:start_date],
      end_date: template[:end_date],
      status: template[:status]
    )
  end
end

CrowquillSeeds.state[:organizations].each do |slug, _organization|
  catalog = CrowquillSeeds::COURSE_CATALOG.fetch(slug)

  CrowquillSeeds.state[:periods_by_org].fetch(slug).each do |status_key, period|
    catalog.fetch(status_key).each do |course_data|
      course = CrowquillSeeds.seed_course(
        academic_period: period,
        name: course_data[:name],
        description: course_data[:description]
      )

      CrowquillSeeds.state[:courses_by_org][slug][status_key] << course

      section_count = status_key == :active ? 2 : 1
      section_count.times do |section_index|
        suffix = ("A".ord + section_index).chr
        section = CrowquillSeeds.seed_section(
          course: course,
          tutors: CrowquillSeeds.state[:org_tutors].fetch(slug),
          suffix: suffix
        )

        CrowquillSeeds.state[:sections_by_org][slug][status_key] << section
      end
    end
  end
end
