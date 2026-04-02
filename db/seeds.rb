# frozen_string_literal: true

# === Organization ===
org = Organization.find_or_create_by!(slug: "pimu-uc") do |o|
  o.name = "PIMU UC"
  o.settings = {
    "max_messages_per_hour" => 30,
    "max_tokens_per_day" => 100_000
  }
end
puts "Organization '#{org.name}' ready."

# === Users ===
admin = User.find_or_create_by!(email: "admin@crowquill.dev") do |u|
  u.name = "Carolina Muñoz"
  u.password = "Password123456"
  u.verified = true
end

tutor1 = User.find_or_create_by!(email: "tutor1@crowquill.dev") do |u|
  u.name = "Sebastián Vega"
  u.password = "Password123456"
  u.verified = true
end

tutor2 = User.find_or_create_by!(email: "tutor2@crowquill.dev") do |u|
  u.name = "Francisca Rojas"
  u.password = "Password123456"
  u.verified = true
end

students = 8.times.map do |i|
  User.find_or_create_by!(email: "alumno#{i + 1}@crowquill.dev") do |u|
    u.name = [
      "Martín González", "Valentina Silva", "Joaquín Pérez", "Isidora López",
      "Tomás Fernández", "Catalina Díaz", "Matías Soto", "Antonia Martínez"
    ][i]
    u.password = "Password123456"
    u.verified = true
  end
end
puts "#{User.count} users ready."

# === Memberships ===
Membership.find_or_create_by!(user: admin, organization: org) { |m| m.role = "admin" }
Membership.find_or_create_by!(user: tutor1, organization: org) { |m| m.role = "tutor" }
Membership.find_or_create_by!(user: tutor2, organization: org) { |m| m.role = "tutor" }
students.each do |student|
  Membership.find_or_create_by!(user: student, organization: org) { |m| m.role = "tutorado" }
end
puts "#{Membership.count} memberships ready."

# === Academic Period ===
period = AcademicPeriod.find_or_create_by!(organization: org, name: "1er Semestre 2026") do |p|
  p.start_date = Date.new(2026, 3, 9)
  p.end_date = Date.new(2026, 7, 17)
  p.status = "active"
end
puts "Academic period '#{period.name}' ready."

# === Courses ===
precalculo = Course.find_or_create_by!(academic_period: period, name: "Precálculo") do |c|
  c.description = "Repaso de funciones, trigonometría y álgebra para preparar Cálculo I."
end

calculo = Course.find_or_create_by!(academic_period: period, name: "Cálculo I") do |c|
  c.description = "Límites, derivadas e introducción a integrales."
end
puts "#{Course.count} courses ready."

# === Sections ===
sec_pre_1 = Section.find_or_create_by!(course: precalculo, name: "Precálculo - Sección A") do |s|
  s.tutor = tutor1
  s.max_students = 12
  s.schedule = {"day" => "monday", "start_time" => "14:00", "end_time" => "15:30", "room" => "S301"}
end

sec_pre_2 = Section.find_or_create_by!(course: precalculo, name: "Precálculo - Sección B") do |s|
  s.tutor = tutor2
  s.max_students = 12
  s.schedule = {"day" => "wednesday", "start_time" => "10:00", "end_time" => "11:30", "room" => "S205"}
end

sec_cal_1 = Section.find_or_create_by!(course: calculo, name: "Cálculo I - Sección A") do |s|
  s.tutor = tutor1
  s.max_students = 12
  s.schedule = {"day" => "thursday", "start_time" => "16:00", "end_time" => "17:30", "room" => "S301"}
end
puts "#{Section.count} sections ready."

# === Enrollments ===
# First 4 students in Precálculo A, next 4 in Precálculo B
students[0..3].each do |student|
  Enrollment.find_or_create_by!(section: sec_pre_1, user: student) do |e|
    e.status = "active"
    e.commitment_accepted_at = Time.current
  end
end

students[4..7].each do |student|
  Enrollment.find_or_create_by!(section: sec_pre_2, user: student) do |e|
    e.status = "active"
    e.commitment_accepted_at = Time.current
  end
end

# Some students also in Cálculo I
students[0..2].each do |student|
  Enrollment.find_or_create_by!(section: sec_cal_1, user: student) do |e|
    e.status = "active"
    e.commitment_accepted_at = Time.current
  end
end
puts "#{Enrollment.count} enrollments ready."

puts ""
puts "=== Login credentials (all passwords: Password123456) ==="
puts "  Admin:    admin@crowquill.dev"
puts "  Tutor 1:  tutor1@crowquill.dev"
puts "  Tutor 2:  tutor2@crowquill.dev"
puts "  Alumno 1: alumno1@crowquill.dev"
puts "==========================================================="
