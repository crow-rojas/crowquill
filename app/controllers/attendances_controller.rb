# frozen_string_literal: true

class AttendancesController < InertiaController
  before_action :set_tutoring_session

  def update
    authorize :attendance, policy_class: AttendancePolicy

    valid_enrollment_ids = @tutoring_session.section.enrollments.pluck(:id)

    ActiveRecord::Base.transaction do
      attendance_params.each do |entry|
        next unless valid_enrollment_ids.include?(entry[:enrollment_id].to_i)

        attendance = @tutoring_session.attendances.find_or_initialize_by(
          enrollment_id: entry[:enrollment_id]
        )
        attendance.status = entry[:status]
        attendance.notes = entry[:notes] if entry.key?(:notes)
        attendance.save!
      end

      if attendance_params.present? && @tutoring_session.scheduled?
        @tutoring_session.update!(status: "completed")
      end
    end

    redirect_to tutoring_session_path(@tutoring_session), notice: t("flash.attendances.saved")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to tutoring_session_path(@tutoring_session), inertia: {errors: e.record.errors}
  end

  private

  def set_tutoring_session
    @tutoring_session = TutoringSession.joins(section: {course: {academic_period: :organization}})
      .where(organizations: {id: Current.organization.id})
      .find(params[:tutoring_session_id])
  end

  def attendance_params
    params.require(:attendances).map do |a|
      a.permit(:enrollment_id, :status, :notes)
    end
  end
end
