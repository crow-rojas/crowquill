# frozen_string_literal: true

class EnrollmentsController < InertiaController
  before_action :set_section, only: %i[index create]
  before_action :set_enrollment, only: %i[update destroy]

  def index
    authorize @section, policy_class: EnrollmentPolicy
    enrollments = scoped_enrollments_for_index

    render inertia: "Enrollments/Index", props: {
      section: @section.as_json(
        include: {tutor: {only: %i[id name email]}, course: {}}
      ),
      enrollments: enrollments.as_json(
        include: {user: {only: %i[id name email]}}
      )
    }
  end

  def create
    authorize :enrollment, policy_class: EnrollmentPolicy
    @section.with_lock do
      if @section.enrollments.active.count >= @section.max_students
        redirect_to section_path(@section), alert: t("flash.enrollments.section_full")
        return
      end

      existing = @section.enrollments.find_by(user_id: enrollment_user.id)
      if existing
        if existing.active?
          redirect_to section_path(@section)
          return
        end

        if existing.update(status: "active", commitment_accepted_at: Time.current)
          redirect_to section_path(@section), notice: t("flash.enrollments.enrolled")
        else
          redirect_to section_path(@section), inertia: {errors: existing.errors}
        end
        return
      end

      @enrollment = @section.enrollments.build(
        user: enrollment_user,
        status: "active",
        commitment_accepted_at: Time.current
      )

      if @enrollment.save
        redirect_to section_path(@section), notice: t("flash.enrollments.enrolled")
      else
        redirect_to section_path(@section), inertia: {errors: @enrollment.errors}
      end
    end
  end

  def update
    authorize @enrollment, policy_class: EnrollmentPolicy
    if @enrollment.update(status: "withdrawn")
      redirect_to section_path(@enrollment.section), notice: t("flash.enrollments.withdrawn")
    else
      redirect_to section_path(@enrollment.section), inertia: {errors: @enrollment.errors}
    end
  end

  def destroy
    authorize @enrollment, policy_class: EnrollmentPolicy
    section = @enrollment.section
    @enrollment.destroy!
    redirect_to section_enrollments_path(section), notice: t("flash.enrollments.deleted")
  end

  private

  def set_section
    @section = Section.joins(course: {academic_period: :organization})
      .where(organizations: {id: Current.organization.id})
      .includes(:tutor, :course)
      .find(params[:section_id])
  end

  def set_enrollment
    @enrollment = Enrollment.joins(section: {course: {academic_period: :organization}})
      .where(organizations: {id: Current.organization.id})
      .find(params[:id])
  end

  def enrollment_user
    if Current.membership.admin? && params.dig(:enrollment, :user_id)
      Current.organization.users.find(params[:enrollment][:user_id])
    else
      Current.user
    end
  end

  def scoped_enrollments_for_index
    base_scope = @section.enrollments.includes(:user).order(created_at: :desc)
    return base_scope unless Current.membership&.tutorado?

    base_scope.where(user_id: Current.user.id)
  end
end
