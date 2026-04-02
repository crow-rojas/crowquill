# frozen_string_literal: true

CrowquillSeeds.reset_state!

puts "Cleaning database..."
[
  AiMessage,
  AiConversation,
  Attendance,
  TutoringSession,
  Enrollment,
  ExerciseSet,
  Section,
  Course,
  AcademicPeriod,
  Membership,
  Session,
  Organization,
  User
].each(&:delete_all)

puts "Seeding Crowquill..."
