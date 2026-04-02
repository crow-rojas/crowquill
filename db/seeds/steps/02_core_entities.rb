# frozen_string_literal: true

puts "- Creating organizations, users, and memberships..."

organizations = [
  CrowquillSeeds.seed_organization(
    slug: "pimu-uc",
    name: "PIMU UC",
    settings: {
      "max_messages_per_hour" => 40,
      "max_tokens_per_day" => 160_000,
      "ai_mode" => "balanced"
    }
  ),
  CrowquillSeeds.seed_organization(
    slug: "mate-usm",
    name: "Centro de Tutorias USM",
    settings: {
      "max_messages_per_hour" => 30,
      "max_tokens_per_day" => 120_000,
      "ai_mode" => "conservative"
    }
  )
]

CrowquillSeeds.state[:organizations] = organizations.index_by(&:slug)

users = CrowquillSeeds.state[:users]
users[:admin_global] = CrowquillSeeds.seed_user(
  email: "admin@crowquill.dev",
  name: "Carolina Munoz"
)
users[:admin_usm] = CrowquillSeeds.seed_user(
  email: "coordinacion@crowquill.dev",
  name: "Diego Soto"
)

CrowquillSeeds.state[:tutors] = CrowquillSeeds::TUTOR_PROFILES.map do |email, name|
  CrowquillSeeds.seed_user(email: email, name: name)
end

CrowquillSeeds.state[:students] = CrowquillSeeds::STUDENT_NAMES.each_with_index.map do |name, index|
  CrowquillSeeds.seed_user(email: "alumno#{index + 1}@crowquill.dev", name: name)
end

CrowquillSeeds.state[:org_admins] = {
  "pimu-uc" => [users.fetch(:admin_global), users.fetch(:admin_usm)],
  "mate-usm" => [users.fetch(:admin_global), users.fetch(:admin_usm)]
}

CrowquillSeeds.state[:org_tutors] = {
  "pimu-uc" => CrowquillSeeds.state[:tutors].first(4),
  "mate-usm" => CrowquillSeeds.state[:tutors].last(4)
}

CrowquillSeeds.state[:org_students] = {
  "pimu-uc" => CrowquillSeeds.state[:students].first(18),
  "mate-usm" => CrowquillSeeds.state[:students][10..]
}

CrowquillSeeds.state[:organizations].each do |slug, organization|
  CrowquillSeeds.state[:org_admins].fetch(slug).each do |admin|
    CrowquillSeeds.seed_membership(user: admin, organization: organization, role: "admin")
  end

  CrowquillSeeds.state[:org_tutors].fetch(slug).each do |tutor|
    CrowquillSeeds.seed_membership(user: tutor, organization: organization, role: "tutor")
  end

  CrowquillSeeds.state[:org_students].fetch(slug).each do |student|
    CrowquillSeeds.seed_membership(user: student, organization: organization, role: "tutorado")
  end
end
