# frozen_string_literal: true

class SectionsController < InertiaController
  before_action :set_course, only: %i[index new create]
  before_action :set_section, only: %i[show edit update destroy]

  def index
    authorize :section, policy_class: SectionPolicy
    sections = visible_sections(@course.sections).includes(:tutor).order(:name)

    render inertia: "Sections/Index", props: {
      course: @course.as_json,
      sections: sections.as_json(include: {tutor: {only: %i[id name email]}})
    }
  end

  def show
    authorize @section, policy_class: SectionPolicy
    current_enrollment = Current.user ? @section.enrollments.find_by(user: Current.user) : nil

    render inertia: "Sections/Show", props: {
      section: @section.as_json(
        include: {tutor: {only: %i[id name email]}, course: {}}
      ),
      enrollments_count: @section.enrollments.active.count,
      current_enrollment: current_enrollment&.as_json,
      is_full: @section.enrollments.active.count >= @section.max_students,
      can_view_enrollments: EnrollmentPolicy.new(Current.membership, @section).index?
    }
  end

  def new
    authorize :section, policy_class: SectionPolicy
    tutors = Current.organization.memberships.where(role: %w[admin tutor]).includes(:user).map do |m|
      m.user.as_json(only: %i[id name email])
    end

    render inertia: "Sections/New", props: {
      course: @course.as_json,
      tutors: tutors
    }
  end

  def create
    authorize :section, policy_class: SectionPolicy
    @section = @course.sections.build(section_params)

    if @section.save
      redirect_to section_path(@section), notice: t("flash.sections.created")
    else
      redirect_to new_course_section_path(@course), inertia: {errors: @section.errors}
    end
  end

  def edit
    authorize @section, policy_class: SectionPolicy
    tutors = Current.organization.memberships.where(role: %w[admin tutor]).includes(:user).map do |m|
      m.user.as_json(only: %i[id name email])
    end

    render inertia: "Sections/Edit", props: {
      section: @section.as_json,
      tutors: tutors
    }
  end

  def update
    authorize @section, policy_class: SectionPolicy

    if @section.update(section_params)
      redirect_to section_path(@section), notice: t("flash.sections.updated")
    else
      redirect_to edit_section_path(@section), inertia: {errors: @section.errors}
    end
  end

  def destroy
    authorize @section, policy_class: SectionPolicy
    course = @section.course
    @section.destroy!
    redirect_to course_sections_path(course), notice: t("flash.sections.deleted")
  end

  private

  def set_course
    @course = Course.joins(academic_period: :organization)
      .where(organizations: {id: Current.organization.id})
      .find(params[:course_id])
  end

  def set_section
    @section = Section.joins(course: {academic_period: :organization})
      .where(organizations: {id: Current.organization.id})
      .includes(:tutor, :course)
      .find(params[:id])
  end

  def section_params
    params.require(:section).permit(:name, :tutor_id, :max_students, schedule: {})
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
end
