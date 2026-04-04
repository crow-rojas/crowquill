# frozen_string_literal: true

class CoursesController < InertiaController
  before_action :set_academic_period, only: %i[index new create]
  before_action :set_course, only: %i[show edit update destroy]

  def index
    authorize :course, policy_class: CoursePolicy
    courses = visible_courses(@academic_period.courses).order(:name)

    render inertia: "Courses/Index", props: {
      academic_period: @academic_period.as_json,
      courses: courses.as_json
    }
  end

  def show
    authorize @course, policy_class: CoursePolicy

    sections = visible_sections(@course.sections).includes(:tutor).order(:name).to_a
    session_visible_section_ids = section_ids_with_visible_sessions(sections)

    sections_payload = sections.map do |section|
      section.as_json(include: {tutor: {only: %i[id name email]}}).merge(
        "can_view_sessions" => session_visible_section_ids.include?(section.id)
      )
    end

    exercise_sets = @course.exercise_sets.ordered
    exercise_sets = exercise_sets.published unless Current.membership&.admin?

    render inertia: "Courses/Show", props: {
      course: @course.as_json.merge(
        "sections" => sections_payload
      ),
      exercise_sets: exercise_sets.as_json(only: %i[id title week_number published])
    }
  end

  def new
    authorize :course, policy_class: CoursePolicy
    render inertia: "Courses/New", props: {
      academic_period: @academic_period.as_json
    }
  end

  def create
    authorize :course, policy_class: CoursePolicy
    @course = @academic_period.courses.build(course_params)

    if @course.save
      redirect_to course_path(@course), notice: t("flash.courses.created")
    else
      redirect_to new_academic_period_course_path(@academic_period), inertia: {errors: @course.errors}
    end
  end

  def edit
    authorize @course, policy_class: CoursePolicy
    render inertia: "Courses/Edit", props: {
      course: @course.as_json
    }
  end

  def update
    authorize @course, policy_class: CoursePolicy

    if @course.update(course_params)
      redirect_to course_path(@course), notice: t("flash.courses.updated")
    else
      redirect_to edit_course_path(@course), inertia: {errors: @course.errors}
    end
  end

  def destroy
    authorize @course, policy_class: CoursePolicy
    academic_period = @course.academic_period
    @course.destroy!
    redirect_to academic_period_courses_path(academic_period), notice: t("flash.courses.deleted")
  end

  private

  def set_academic_period
    @academic_period = Current.organization.academic_periods.find(params[:academic_period_id])
  end

  def set_course
    @course = Course.joins(academic_period: :organization)
      .where(organizations: {id: Current.organization.id})
      .find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :description)
  end

  def visible_courses(scope)
    return scope if Current.membership&.admin?

    if Current.membership&.tutor?
      scope.joins(:sections).where(sections: {tutor_id: Current.user.id}).distinct
    elsif Current.membership&.tutorado?
      scope.joins(sections: :enrollments)
        .where(enrollments: {user_id: Current.user.id, status: "active"})
        .distinct
    else
      scope.none
    end
  end

  def visible_sections(scope)
    return scope if Current.membership&.admin?

    if Current.membership&.tutor?
      scope.where(tutor_id: Current.user.id)
    elsif Current.membership&.tutorado?
      visible_section_ids = tutorado_visible_section_ids(scope)
      scope.where(id: visible_section_ids)
    else
      scope.none
    end
  end

  def tutorado_visible_section_ids(scope)
    section_rows = scope.select(:id, :max_students).to_a
    return [] if section_rows.empty?

    section_ids = section_rows.map(&:id)
    active_counts = Enrollment.where(section_id: section_ids, status: "active").group(:section_id).count
    enrolled_section_ids = Enrollment.where(
      section_id: section_ids,
      user_id: Current.user.id,
      status: "active"
    ).pluck(:section_id)

    section_rows.filter_map do |section|
      active_count = active_counts.fetch(section.id, 0)
      section.id if enrolled_section_ids.include?(section.id) || active_count < section.max_students
    end
  end

  def section_ids_with_visible_sessions(sections)
    return [] if sections.empty?
    return sections.map(&:id) if Current.membership&.admin?

    if Current.membership&.tutor?
      return sections.filter_map do |section|
        section.id if section.tutor_id == Current.user.id
      end
    end

    if Current.membership&.tutorado?
      return Enrollment.where(
        section_id: sections.map(&:id),
        user_id: Current.user.id,
        status: "active"
      ).pluck(:section_id)
    end

    []
  end
end
