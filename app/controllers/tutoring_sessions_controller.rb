# frozen_string_literal: true

class TutoringSessionsController < InertiaController
  before_action :set_section, only: %i[index new create]
  before_action :set_tutoring_session, only: %i[show edit update destroy]

  def index
    authorize @section, policy_class: TutoringSessionPolicy
    sessions = @section.tutoring_sessions.order(date: :desc)

    render inertia: "TutoringSessions/Index", props: {
      section: @section.as_json(
        include: {tutor: {only: %i[id name email]}, course: {}}
      ),
      tutoring_sessions: sessions.as_json,
      can_create_session: TutoringSessionPolicy.new(Current.membership, @section).new?,
      can_delete_session: SectionPolicy.new(Current.membership, @section).destroy?
    }
  end

  def show
    authorize @tutoring_session, policy_class: TutoringSessionPolicy
    section = @tutoring_session.section
    can_take_attendance = AttendancePolicy.new(Current.membership, @tutoring_session).update?

    if can_take_attendance
      enrollments = section.enrollments.active.includes(:user)
      attendances = @tutoring_session.attendances.includes(enrollment: :user)
    else
      enrollments = section.enrollments.active.where(user_id: Current.user.id).includes(:user)
      attendances = @tutoring_session.attendances
        .joins(:enrollment)
        .where(enrollments: {user_id: Current.user.id})
        .includes(enrollment: :user)
    end

    exercise_sets, exercise_match_type = load_exercise_sets(section)
    ai_chat_exercise_set_id = exercise_match_type == "week" ? exercise_sets.first&.id : nil

    student_summaries = if can_take_attendance
      build_student_summaries(section)
    end

    render inertia: "TutoringSessions/Show", props: {
      tutoring_session: @tutoring_session.as_json(
        include: {section: {include: {course: {}, tutor: {only: %i[id name email]}}}}
      ),
      enrollments: enrollments.as_json(
        include: {user: {only: %i[id name email]}}
      ),
      attendances: attendances.as_json(
        include: {enrollment: {include: {user: {only: %i[id name email]}}}}
      ),
      can_manage_session: TutoringSessionPolicy.new(Current.membership, @tutoring_session).update?,
      can_take_attendance: can_take_attendance,
      can_delete_session: SectionPolicy.new(Current.membership, @tutoring_session.section).destroy?,
      exercise_sets: exercise_sets.as_json(only: %i[id title week_number content published]),
      exercise_match_type: exercise_match_type,
      ai_chat_exercise_set_id: ai_chat_exercise_set_id,
      student_summaries: student_summaries
    }
  end

  def new
    authorize @section, policy_class: TutoringSessionPolicy

    render inertia: "TutoringSessions/New", props: {
      section: @section.as_json(
        include: {tutor: {only: %i[id name email]}, course: {}}
      )
    }
  end

  def create
    @tutoring_session = @section.tutoring_sessions.build(tutoring_session_params)
    authorize @tutoring_session, policy_class: TutoringSessionPolicy

    if @tutoring_session.save
      redirect_to tutoring_session_path(@tutoring_session), notice: t("flash.tutoring_sessions.created")
    else
      redirect_to new_section_tutoring_session_path(@section), inertia: {errors: @tutoring_session.errors}
    end
  end

  def edit
    authorize @tutoring_session, policy_class: TutoringSessionPolicy

    render inertia: "TutoringSessions/Edit", props: {
      tutoring_session: @tutoring_session.as_json(
        include: {section: {include: {course: {}}}}
      )
    }
  end

  def update
    authorize @tutoring_session, policy_class: TutoringSessionPolicy

    if @tutoring_session.update(tutoring_session_params)
      redirect_to tutoring_session_path(@tutoring_session), notice: t("flash.tutoring_sessions.updated")
    else
      redirect_to edit_tutoring_session_path(@tutoring_session), inertia: {errors: @tutoring_session.errors}
    end
  end

  def destroy
    authorize @tutoring_session, policy_class: TutoringSessionPolicy
    section = @tutoring_session.section
    @tutoring_session.destroy!
    redirect_to section_tutoring_sessions_path(section), notice: t("flash.tutoring_sessions.deleted")
  end

  private

  def set_section
    @section = Section.joins(course: {academic_period: :organization})
      .where(organizations: {id: Current.organization.id})
      .includes(:tutor, :course)
      .find(params[:section_id])
  end

  def set_tutoring_session
    @tutoring_session = TutoringSession.joins(section: {course: {academic_period: :organization}})
      .where(organizations: {id: Current.organization.id})
      .find(params[:id])
  end

  def tutoring_session_params
    params.require(:tutoring_session).permit(:date, :status)
  end

  def load_exercise_sets(section)
    course = section.course
    academic_period = course.academic_period
    session_week = [(((@tutoring_session.date - academic_period.start_date).to_i / 7) + 1), 1].max

    week_sets = course.exercise_sets.where(week_number: session_week).ordered
    week_sets = week_sets.published unless Current.membership&.admin?

    if week_sets.any?
      [week_sets, "week"]
    else
      all_sets = course.exercise_sets.ordered
      all_sets = all_sets.published unless Current.membership&.admin?
      [all_sets, "all"]
    end
  end

  def build_student_summaries(section)
    raw = Attendance.where(tutoring_session_id: section.tutoring_session_ids)
      .group(:enrollment_id, :status).count

    summaries = {}
    raw.each do |(enrollment_id, status), count|
      summaries[enrollment_id] ||= {"present" => 0, "absent" => 0, "justified" => 0}
      summaries[enrollment_id][status] = count
    end
    summaries
  end
end
