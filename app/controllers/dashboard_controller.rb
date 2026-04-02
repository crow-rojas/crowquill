# frozen_string_literal: true

class DashboardController < InertiaController
  skip_verify_authorized :index

  def index
    case Current.membership&.role
    when "admin"
      render_admin_dashboard
    when "tutor"
      render_tutor_dashboard
    when "tutorado"
      render_tutorado_dashboard
    else
      render inertia: "dashboard/index", props: {}
    end
  end

  private

  def organization
    Current.organization
  end

  def active_period
    @active_period ||= organization.academic_periods.find_by(status: "active")
  end

  def render_admin_dashboard
    period_courses = active_period ? active_period.courses : Course.none
    sections = Section.where(course: period_courses)

    total_students = Membership.where(organization: organization, role: "tutorado").count
    total_tutors = Membership.where(organization: organization, role: "tutor").count
    active_sections = sections.count

    recent_sessions = TutoringSession
      .where(section: sections)
      .includes(section: {course: :academic_period}, attendances: :enrollment)
      .order(date: :desc)
      .limit(5)

    render inertia: "dashboard/index", props: {
      role: "admin",
      active_period: active_period&.as_json(only: %i[id name start_date end_date status]),
      total_students: total_students,
      total_tutors: total_tutors,
      active_sections: active_sections,
      recent_sessions: recent_sessions.map { |s| session_json(s) }
    }
  end

  def render_tutor_dashboard
    my_sections = Section
      .where(tutor: Current.user)
      .includes(course: {academic_period: :organization})
      .where(courses: {academic_periods: {status: "active", organization_id: organization.id}})

    section_ids = my_sections.pluck(:id)

    upcoming_sessions = TutoringSession
      .where(section_id: section_ids)
      .upcoming
      .includes(section: :course)
      .limit(10)

    enrollment_counts = Enrollment.where(section_id: section_ids, status: "active")
      .group(:section_id).count

    render inertia: "dashboard/index", props: {
      role: "tutor",
      my_sections: my_sections.map { |s|
        s.as_json(only: %i[id name schedule max_students]).merge(
          course: s.course.as_json(only: %i[id name]),
          enrollments_count: enrollment_counts[s.id] || 0
        )
      },
      upcoming_sessions: upcoming_sessions.map { |s| session_json(s) }
    }
  end

  def render_tutorado_dashboard
    my_enrollments = Enrollment
      .where(user: Current.user, status: "active")
      .includes(section: {course: {academic_period: :organization}})
      .where(courses: {academic_periods: {status: "active", organization_id: organization.id}})

    section_ids = my_enrollments.pluck(:section_id)

    upcoming_sessions = TutoringSession
      .where(section_id: section_ids)
      .upcoming
      .includes(section: :course)
      .limit(10)

    course_ids = Section.where(id: section_ids).pluck(:course_id).uniq
    recent_exercises = ExerciseSet
      .where(course_id: course_ids)
      .published
      .ordered
      .limit(5)

    render inertia: "dashboard/index", props: {
      role: "tutorado",
      my_sections: my_enrollments.map { |e|
        section = e.section
        section.as_json(only: %i[id name schedule]).merge(
          course: section.course.as_json(only: %i[id name])
        )
      },
      upcoming_sessions: upcoming_sessions.map { |s| session_json(s) },
      recent_exercises: recent_exercises.as_json(only: %i[id title week_number course_id])
    }
  end

  def session_json(session)
    json = session.as_json(only: %i[id date status])
    json[:section] = session.section.as_json(only: %i[id name])
    json[:course] = session.section.course.as_json(only: %i[id name])

    if Current.membership&.admin? || Current.membership&.tutor?
      json[:attendance_count] = session.attendances.size
    end

    json
  end
end
