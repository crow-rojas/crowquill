# frozen_string_literal: true

module CrowquillSeeds
  class << self
    def pick(values)
      values.fetch(random.rand(values.length))
    end

    def seed_organization(slug:, name:, settings:)
      Organization.find_or_create_by!(slug: slug) do |organization|
        organization.name = name
        organization.settings = settings
      end
    end

    def seed_user(email:, name:, verified: true)
      User.find_or_create_by!(email: email) do |user|
        user.name = name
        user.password = DEFAULT_PASSWORD
        user.verified = verified
      end
    end

    def seed_membership(user:, organization:, role:)
      Membership.find_or_create_by!(user: user, organization: organization) do |membership|
        membership.role = role
      end
    end

    def semester_windows(reference_date = Date.current)
      year = reference_date.year

      if reference_date.month <= 7
        {
          archived: {
            year: year - 1, semester: 2, name: "2do Semestre #{year - 1}",
            start_date: Date.new(year - 1, 8, 1),
            end_date: Date.new(year - 1, 12, 20),
            status: "archived"
          },
          active: {
            year: year, semester: 1, name: "1er Semestre #{year}",
            start_date: Date.new(year, 3, 1),
            end_date: Date.new(year, 7, 31),
            status: "active"
          },
          draft: {
            year: year, semester: 2, name: "2do Semestre #{year}",
            start_date: Date.new(year, 8, 1),
            end_date: Date.new(year, 12, 20),
            status: "draft"
          }
        }
      else
        {
          archived: {
            year: year, semester: 1, name: "1er Semestre #{year}",
            start_date: Date.new(year, 3, 1),
            end_date: Date.new(year, 7, 31),
            status: "archived"
          },
          active: {
            year: year, semester: 2, name: "2do Semestre #{year}",
            start_date: Date.new(year, 8, 1),
            end_date: Date.new(year, 12, 20),
            status: "active"
          },
          draft: {
            year: year + 1, semester: 1, name: "1er Semestre #{year + 1}",
            start_date: Date.new(year + 1, 3, 1),
            end_date: Date.new(year + 1, 7, 31),
            status: "draft"
          }
        }
      end
    end

    def seed_period(organization:, year:, semester:, name:, start_date:, end_date:, status:)
      AcademicPeriod.find_or_create_by!(organization: organization, year: year, semester: semester) do |period|
        period.name = name
        period.start_date = start_date
        period.end_date = end_date
        period.status = status
      end
    end

    def seed_course(academic_period:, name:, description:)
      Course.find_or_create_by!(academic_period: academic_period, name: name) do |course|
        course.description = description
      end
    end

    def random_schedule
      day = pick(DAY_OFFSETS.keys)
      alternate_day = pick(DAY_OFFSETS.keys - [day])
      start_time, end_time = pick(TIME_SLOTS)
      room = pick(ROOMS)

      case random.rand(4)
      when 0
        {
          "day" => day,
          "start_time" => start_time,
          "end_time" => end_time,
          "room" => room
        }
      when 1
        {
          day => {
            "start_time" => start_time,
            "end_time" => end_time,
            "room" => room
          }
        }
      when 2
        {
          day => {
            "start_time" => start_time,
            "end_time" => end_time,
            "room" => room
          },
          alternate_day => {
            "start_time" => start_time,
            "end_time" => end_time,
            "room" => room
          }
        }
      else
        {
          day => "#{start_time} - #{end_time}"
        }
      end
    end

    def seed_section(course:, tutors:, suffix:)
      Section.find_or_create_by!(course: course, name: "#{course.name} - Seccion #{suffix}") do |section|
        section.tutor = pick(tutors)
        section.max_students = pick([10, 12, 14, 16, 18])
        section.schedule = random_schedule
      end
    end

    def primary_schedule_day(schedule)
      return schedule["day"].to_s.downcase if schedule.is_a?(Hash) && schedule["day"].present?

      if schedule.is_a?(Hash) && schedule.keys.any?
        schedule.keys.first.to_s.downcase
      else
        "monday"
      end
    end

    def align_to_schedule_day(date:, schedule:)
      day = primary_schedule_day(schedule)
      offset = DAY_OFFSETS.fetch(day, 0)
      date.beginning_of_week(:monday) + offset.days
    end

    def seed_enrollments(section:, students:, occupancy_range:, allow_withdrawals: true)
      max_size = [section.max_students, students.size].min
      return [] if max_size.zero?

      lower_bound = [(max_size * occupancy_range.begin).floor, 0].max
      upper_bound = [(max_size * occupancy_range.end).ceil, lower_bound].max
      target_size = random.rand(lower_bound..upper_bound)

      chosen_students = students.sample(target_size, random: random)

      seeded_enrollments = chosen_students.map do |student|
        Enrollment.find_or_create_by!(section: section, user: student) do |enrollment|
          enrollment.status = "active"
          enrollment.commitment_accepted_at = random.rand(5..140).days.ago
        end
      end

      if allow_withdrawals && seeded_enrollments.size > 1
        withdrawal_percent = random.rand(8..20)
        withdrawal_count = (seeded_enrollments.size * withdrawal_percent / 100.0).round
        withdrawal_count = [[withdrawal_count, 1].max, seeded_enrollments.size - 1].min

        seeded_enrollments.sample(withdrawal_count, random: random).each do |enrollment|
          enrollment.update!(status: "withdrawn")
        end
      end

      seeded_enrollments
    end

    def attendance_status
      roll = random.rand(100)
      return "present" if roll < 74
      return "absent" if roll < 89

      "justified"
    end

    def session_status_for_date(session_date:, period_status:)
      if session_date < Date.current
        completed_threshold = period_status == "draft" ? 35 : 84
        random.rand(100) < completed_threshold ? "completed" : "cancelled"
      else
        random.rand(100) < 90 ? "scheduled" : "cancelled"
      end
    end

    def seed_attendance_for_session(session:)
      session.section.enrollments.active.find_each do |enrollment|
        status = attendance_status

        Attendance.find_or_create_by!(tutoring_session: session, enrollment: enrollment) do |attendance|
          attendance.status = status
          attendance.notes = status == "justified" ? pick(JUSTIFICATION_NOTES) : nil
        end
      end
    end

    def seed_tutoring_sessions(section:, period:, period_status:)
      total_weeks = case period_status
      when "archived"
        10
      when "active"
        10
      else
        6
      end

      (0...total_weeks).each do |week_index|
        base_date = period.start_date + week_index.weeks
        session_date = align_to_schedule_day(date: base_date, schedule: section.schedule)
        status = session_status_for_date(session_date: session_date, period_status: period_status)

        tutoring_session = TutoringSession.find_or_create_by!(section: section, date: session_date) do |record|
          record.status = status
        end

        tutoring_session.update!(status: status) if tutoring_session.status != status

        seed_attendance_for_session(session: tutoring_session) if tutoring_session.completed?
      end

      return unless %w[active draft].include?(period_status)

      upcoming_base = [Date.current + 7.days, period.start_date].max
      upcoming_date = align_to_schedule_day(date: upcoming_base, schedule: section.schedule)

      upcoming_session = TutoringSession.find_or_create_by!(section: section, date: upcoming_date) do |record|
        record.status = "scheduled"
      end
      upcoming_session.update!(status: "scheduled") unless upcoming_session.scheduled?
    end

    def topics_for_course(course_name)
      normalized = I18n.transliterate(course_name).downcase

      case normalized
      when /precalculo/
        [
          "Functions and domain",
          "Applied trigonometry",
          "Inequalities",
          "Logarithms and exponentials",
          "Function modeling"
        ]
      when /calculo i/
        [
          "Limits",
          "Basic derivatives",
          "Chain rule",
          "Derivative applications",
          "Optimization"
        ]
      when /calculo ii/
        [
          "Definite integrals",
          "Integration techniques",
          "Area between curves",
          "Numeric series",
          "Applied physics context"
        ]
      when /algebra lineal/
        [
          "Linear systems",
          "Vector spaces",
          "Linear transformations",
          "Eigenvalues and eigenvectors",
          "Diagonalization"
        ]
      when /probabilidad|estadistica/
        [
          "Conditional probability",
          "Random variables",
          "Distributions",
          "Inference",
          "Estimation"
        ]
      when /ecuaciones diferenciales/
        [
          "First-order ODE",
          "Linear ODE",
          "Dynamic systems",
          "Laplace transform",
          "Growth models"
        ]
      else
        GENERIC_TOPIC_POOL
      end
    end

    def exercise_published?(period_status:, week_number:)
      case period_status
      when "archived"
        true
      when "active"
        week_number <= 4 || random.rand(100) < 35
      else
        random.rand(100) < 15
      end
    end

    def build_exercise_content(course_name:, topic:, week_number:)
      primary_formula = pick(CONTENT_FORMULAS)
      secondary_formula = pick(CONTENT_FORMULAS - [primary_formula])

      <<~MARKDOWN
        ## #{course_name} - #{topic}

        Week #{week_number}. Provide concise reasoning for each main step.

        ### Problem 1
        Analyze the expression:
        $$#{primary_formula}$$

        1. Identify domain restrictions, if any.
        2. Evaluate behavior at two test values.
        3. Explain your conclusion in plain language.

        ### Problem 2
        Work with the function:
        $$#{secondary_formula}$$

        1. Propose a short strategy.
        2. Solve and verify numerically.
        3. Mention one common mistake and how to avoid it.

        ### Optional challenge
        Connect this exercise to a practical context from your studies.
      MARKDOWN
    end

    def seed_exercise_sets(course:, period_status:)
      total_weeks = case period_status
      when "archived"
        6
      when "active"
        7
      else
        4
      end

      topics = topics_for_course(course.name)
      difficulty_cycle = %w[easy medium hard]

      (1..total_weeks).each do |week_number|
        topic = topics[(week_number - 1) % topics.length]

        ExerciseSet.find_or_create_by!(course: course, week_number: week_number) do |exercise_set|
          exercise_set.title = "#{topic} (Week #{week_number})"
          exercise_set.content = build_exercise_content(
            course_name: course.name,
            topic: topic,
            week_number: week_number
          )
          exercise_set.published = exercise_published?(
            period_status: period_status,
            week_number: week_number
          )
          exercise_set.metadata = {
            "difficulty" => difficulty_cycle[(week_number - 1) % difficulty_cycle.size],
            "estimated_minutes" => random.rand(30..95),
            "skills" => [topic, pick(GENERIC_TOPIC_POOL)].uniq,
            "review_required" => week_number.even?
          }
        end
      end
    end

    def seed_ai_conversation(user:, title:, exercise_set:, include_failed: false, include_streaming: false)
      conversation = AiConversation.find_or_create_by!(user: user, title: title) do |record|
        record.exercise_set = exercise_set
      end

      return conversation if conversation.ai_messages.exists?

      conversation.ai_messages.create!(
        role: "user",
        status: "complete",
        content: pick(AI_PROMPTS)
      )

      conversation.ai_messages.create!(
        role: "assistant",
        status: "complete",
        content: pick(AI_RESPONSES),
        input_tokens: random.rand(120..260),
        output_tokens: random.rand(80..220)
      )

      conversation.ai_messages.create!(
        role: "user",
        status: "complete",
        content: "Could you provide one extra hint so I can continue on my own?"
      )

      if include_failed
        conversation.ai_messages.create!(
          role: "assistant",
          status: "failed",
          content: "I had a processing issue while finishing the response. Please retry in a few seconds."
        )
      else
        conversation.ai_messages.create!(
          role: "assistant",
          status: "complete",
          content: "Great. Re-check assumptions first, then apply the method step by step.",
          input_tokens: random.rand(140..280),
          output_tokens: random.rand(90..240)
        )
      end

      conversation.ai_messages.create!(role: "assistant", status: "streaming") if include_streaming

      conversation
    end
  end
end
