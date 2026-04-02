# frozen_string_literal: true

class AttendancesController < InertiaController
  before_action :set_tutoring_session

  def update
    authorize! nil, policy_class: AttendancePolicy

    ActiveRecord::Base.transaction do
      attendance_params.each do |entry|
        attendance = @tutoring_session.attendances.find_or_initialize_by(
          enrollment_id: entry[:enrollment_id]
        )
        attendance.status = entry[:status]
        attendance.notes = entry[:notes] if entry.key?(:notes)
        attendance.save!
      end

      @tutoring_session.update!(status: "completed")
    end

    redirect_to tutoring_session_path(@tutoring_session), notice: "Attendance saved successfully."
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
