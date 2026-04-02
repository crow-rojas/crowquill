# frozen_string_literal: true

puts "- Creating AI conversations and messages..."

published_exercises = ExerciseSet.where(published: true).to_a
all_exercises = ExerciseSet.all.to_a

if all_exercises.empty?
  puts "  Skipping AI conversations because no exercise sets were seeded."
  return
end

if published_exercises.empty?
  published_exercises = all_exercises
end

pimu_students = Array(CrowquillSeeds.state[:org_students]["pimu-uc"]).first(8)
usm_students = Array(CrowquillSeeds.state[:org_students]["mate-usm"]).first(6)
ai_students = (pimu_students + usm_students).compact.uniq

ai_students.each_with_index do |student, index|
  primary_title = "#{CrowquillSeeds::CONVERSATION_PREFIXES[index % CrowquillSeeds::CONVERSATION_PREFIXES.size]} ##{index + 1}"
  primary_exercise = published_exercises[index % published_exercises.size]

  CrowquillSeeds.seed_ai_conversation(
    user: student,
    title: primary_title,
    exercise_set: primary_exercise,
    include_failed: false,
    include_streaming: (index % 4).zero?
  )

  next unless index.even?

  secondary_title = "Follow-up #{index + 1}: #{CrowquillSeeds.pick(CrowquillSeeds::GENERIC_TOPIC_POOL)}"
  secondary_exercise = all_exercises[(index * 3) % all_exercises.size]

  CrowquillSeeds.seed_ai_conversation(
    user: student,
    title: secondary_title,
    exercise_set: secondary_exercise,
    include_failed: true,
    include_streaming: false
  )
end

sample_tutors = [CrowquillSeeds.state[:tutors].first, CrowquillSeeds.state[:tutors].last].compact
sample_tutors.each_with_index do |tutor, index|
  CrowquillSeeds.seed_ai_conversation(
    user: tutor,
    title: "Lesson planning #{index + 1}",
    exercise_set: published_exercises[(index + 2) % published_exercises.size],
    include_failed: false,
    include_streaming: true
  )
end
