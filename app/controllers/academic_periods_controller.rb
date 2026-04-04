# frozen_string_literal: true

class AcademicPeriodsController < InertiaController
  before_action :set_academic_period, only: %i[show edit update destroy]

  def index
    authorize :academic_period, policy_class: AcademicPeriodPolicy
    academic_periods = Current.organization.academic_periods.order(start_date: :desc)

    render inertia: "AcademicPeriods/Index", props: {
      academic_periods: academic_periods.as_json
    }
  end

  def show
    authorize @academic_period, policy_class: AcademicPeriodPolicy
    render inertia: "AcademicPeriods/Show", props: {
      academic_period: @academic_period.as_json(include: :courses)
    }
  end

  def new
    authorize :academic_period, policy_class: AcademicPeriodPolicy
    render inertia: "AcademicPeriods/New"
  end

  def create
    authorize :academic_period, policy_class: AcademicPeriodPolicy
    @academic_period = Current.organization.academic_periods.build(academic_period_params)

    if @academic_period.save
      redirect_to academic_period_path(@academic_period), notice: t("flash.academic_periods.created")
    else
      redirect_to new_academic_period_path, inertia: {errors: @academic_period.errors}
    end
  end

  def edit
    authorize @academic_period, policy_class: AcademicPeriodPolicy
    render inertia: "AcademicPeriods/Edit", props: {
      academic_period: @academic_period.as_json
    }
  end

  def update
    authorize @academic_period, policy_class: AcademicPeriodPolicy

    if @academic_period.update(academic_period_params)
      redirect_to academic_period_path(@academic_period), notice: t("flash.academic_periods.updated")
    else
      redirect_to edit_academic_period_path(@academic_period), inertia: {errors: @academic_period.errors}
    end
  end

  def destroy
    authorize @academic_period, policy_class: AcademicPeriodPolicy
    @academic_period.destroy!
    redirect_to academic_periods_path, notice: t("flash.academic_periods.deleted")
  end

  private

  def set_academic_period
    @academic_period = Current.organization.academic_periods.find(params[:id])
  end

  def academic_period_params
    params.require(:academic_period).permit(:year, :semester, :name, :start_date, :end_date, :status)
  end
end
