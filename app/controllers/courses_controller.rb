# frozen_string_literal: true

class CoursesController < InertiaController
  before_action :set_academic_period, only: %i[index new create]
  before_action :set_course, only: %i[show edit update destroy]

  def index
    authorize! nil, policy_class: CoursePolicy
    courses = @academic_period.courses.order(:name)

    render inertia: "Courses/Index", props: {
      academic_period: @academic_period.as_json,
      courses: courses.as_json
    }
  end

  def show
    authorize! @course, policy_class: CoursePolicy

    exercise_sets = @course.exercise_sets.ordered
    exercise_sets = exercise_sets.published unless Current.membership&.admin?

    render inertia: "Courses/Show", props: {
      course: @course.as_json(include: {sections: {include: {tutor: {only: %i[id name email]}}}}),
      exercise_sets: exercise_sets.as_json(only: %i[id title week_number published])
    }
  end

  def new
    authorize! nil, policy_class: CoursePolicy
    render inertia: "Courses/New", props: {
      academic_period: @academic_period.as_json
    }
  end

  def create
    authorize! nil, policy_class: CoursePolicy
    @course = @academic_period.courses.build(course_params)

    if @course.save
      redirect_to course_path(@course), notice: "Course created successfully."
    else
      redirect_to new_academic_period_course_path(@academic_period), inertia: {errors: @course.errors}
    end
  end

  def edit
    authorize! @course, policy_class: CoursePolicy
    render inertia: "Courses/Edit", props: {
      course: @course.as_json
    }
  end

  def update
    authorize! @course, policy_class: CoursePolicy

    if @course.update(course_params)
      redirect_to course_path(@course), notice: "Course updated successfully."
    else
      redirect_to edit_course_path(@course), inertia: {errors: @course.errors}
    end
  end

  def destroy
    authorize! @course, policy_class: CoursePolicy
    academic_period = @course.academic_period
    @course.destroy!
    redirect_to academic_period_courses_path(academic_period), notice: "Course deleted successfully."
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
end
