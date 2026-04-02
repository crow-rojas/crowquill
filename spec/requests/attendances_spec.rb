# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attendances", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }

  let(:admin_user) { create(:user) }
  let(:admin_membership) { create(:membership, :admin, user: admin_user, organization: organization) }

  let(:tutor_user) { create(:user) }
  let(:tutor_membership) { create(:membership, :tutor, user: tutor_user, organization: organization) }

  let(:tutorado_user) { create(:user) }
  let(:tutorado_membership) { create(:membership, :tutorado, user: tutorado_user, organization: organization) }

  let(:section) { create(:section, course: course, tutor: tutor_user, max_students: 10) }
  let(:tutoring_session) { create(:tutoring_session, section: section) }

  let(:student1) { create(:user) }
  let(:student2) { create(:user) }
  let(:enrollment1) { create(:enrollment, section: section, user: student1) }
  let(:enrollment2) { create(:enrollment, section: section, user: student2) }

  before do
    tutor_membership
  end

  describe "PATCH /tutoring_sessions/:tutoring_session_id/attendances" do
    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "creates attendance records and marks session completed" do
        expect {
          patch tutoring_session_attendances_path(tutoring_session), params: {
            attendances: [
              {enrollment_id: enrollment1.id, status: "present"},
              {enrollment_id: enrollment2.id, status: "absent"}
            ]
          }
        }.to change(Attendance, :count).by(2)

        expect(tutoring_session.reload.status).to eq("completed")
        expect(response).to redirect_to(tutoring_session_path(tutoring_session))
      end

      it "updates existing attendance records" do
        create(:attendance, tutoring_session: tutoring_session, enrollment: enrollment1, status: "absent")

        expect {
          patch tutoring_session_attendances_path(tutoring_session), params: {
            attendances: [
              {enrollment_id: enrollment1.id, status: "present"},
              {enrollment_id: enrollment2.id, status: "justified", notes: "Doctor appointment"}
            ]
          }
        }.to change(Attendance, :count).by(1)

        expect(Attendance.find_by(enrollment: enrollment1).status).to eq("present")
        expect(Attendance.find_by(enrollment: enrollment2).status).to eq("justified")
        expect(Attendance.find_by(enrollment: enrollment2).notes).to eq("Doctor appointment")
      end

      it "performs upsert atomically" do
        create(:attendance, tutoring_session: tutoring_session, enrollment: enrollment1, status: "absent")

        patch tutoring_session_attendances_path(tutoring_session), params: {
          attendances: [
            {enrollment_id: enrollment1.id, status: "present"},
            {enrollment_id: enrollment2.id, status: "absent"}
          ]
        }

        expect(Attendance.count).to eq(2)
        expect(tutoring_session.reload).to be_completed
      end
    end

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "can submit attendance" do
        patch tutoring_session_attendances_path(tutoring_session), params: {
          attendances: [
            {enrollment_id: enrollment1.id, status: "present"}
          ]
        }
        expect(Attendance.count).to eq(1)
        expect(response).to redirect_to(tutoring_session_path(tutoring_session))
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "is not authorized" do
        patch tutoring_session_attendances_path(tutoring_session), params: {
          attendances: [
            {enrollment_id: enrollment1.id, status: "present"}
          ]
        }
        expect(Attendance.count).to eq(0)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
