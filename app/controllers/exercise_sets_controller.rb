# frozen_string_literal: true

class ExerciseSetsController < InertiaController
  before_action :set_course, only: %i[index new create]
  before_action :set_exercise_set, only: %i[show edit update destroy publish unpublish]

  def index
    authorize :exercise_set, policy_class: ExerciseSetPolicy
    exercise_sets = @course.exercise_sets.ordered

    unless Current.membership.admin?
      exercise_sets = exercise_sets.published
    end

    render inertia: "ExerciseSets/Index", props: {
      course: @course.as_json,
      exercise_sets: exercise_sets.as_json
    }
  end

  def show
    authorize @exercise_set, policy_class: ExerciseSetPolicy

    render inertia: "ExerciseSets/Show", props: {
      exercise_set: @exercise_set.as_json(include: :course)
    }
  end

  def new
    authorize :exercise_set, policy_class: ExerciseSetPolicy
    render inertia: "ExerciseSets/New", props: {
      course: @course.as_json
    }
  end

  def create
    authorize :exercise_set, policy_class: ExerciseSetPolicy
    @exercise_set = @course.exercise_sets.build(exercise_set_params)

    if @exercise_set.save
      redirect_to exercise_set_path(@exercise_set), notice: t("flash.exercise_sets.created")
    else
      redirect_to new_course_exercise_set_path(@course), inertia: {errors: @exercise_set.errors}
    end
  end

  def edit
    authorize @exercise_set, policy_class: ExerciseSetPolicy
    render inertia: "ExerciseSets/Edit", props: {
      exercise_set: @exercise_set.as_json(include: :course)
    }
  end

  def update
    authorize @exercise_set, policy_class: ExerciseSetPolicy

    if @exercise_set.update(exercise_set_params)
      redirect_to exercise_set_path(@exercise_set), notice: t("flash.exercise_sets.updated")
    else
      redirect_to edit_exercise_set_path(@exercise_set), inertia: {errors: @exercise_set.errors}
    end
  end

  def destroy
    authorize @exercise_set, policy_class: ExerciseSetPolicy
    course = @exercise_set.course
    @exercise_set.destroy!
    redirect_to course_exercise_sets_path(course), notice: t("flash.exercise_sets.deleted")
  end

  def publish
    authorize @exercise_set, policy_class: ExerciseSetPolicy
    @exercise_set.update!(published: true)
    redirect_to exercise_set_path(@exercise_set), notice: t("flash.exercise_sets.published")
  end

  def unpublish
    authorize @exercise_set, policy_class: ExerciseSetPolicy
    @exercise_set.update!(published: false)
    redirect_to exercise_set_path(@exercise_set), notice: t("flash.exercise_sets.unpublished")
  end

  private

  def set_course
    @course = Course.joins(academic_period: :organization)
      .where(organizations: {id: Current.organization.id})
      .find(params[:course_id])
  end

  def set_exercise_set
    @exercise_set = ExerciseSet.joins(course: {academic_period: :organization})
      .where(organizations: {id: Current.organization.id})
      .find(params[:id])
  end

  def exercise_set_params
    params.require(:exercise_set).permit(:title, :week_number, :content, :published)
  end
end
