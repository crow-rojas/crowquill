# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Enrollments", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }

  let(:admin_user) { create(:user) }
  let(:admin_membership) { create(:membership, :admin, user: admin_user, organization: organization) }

  let(:tutor_user) { create(:user) }
  let(:tutor_membership) { create(:membership, :tutor, user: tutor_user, organization: organization) }

  let(:tutorado_user) { create(:user) }
  let(:tutorado_membership) { create(:membership, :tutorado, user: tutorado_user, organization: organization) }

  let(:section) { create(:section, course: course, tutor: tutor_user, max_students: 3) }

  before do
    tutor_membership
  end

  describe "GET /sections/:section_id/enrollments" do
    before { create(:enrollment, section: section, user: tutorado_user) }

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get section_enrollments_path(section)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "returns success" do
        get section_enrollments_path(section)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /sections/:section_id/enrollments" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "enrolls a student" do
        tutorado_membership
        expect {
          post section_enrollments_path(section), params: {enrollment: {user_id: tutorado_user.id}}
        }.to change(Enrollment, :count).by(1)
        expect(response).to redirect_to(section_path(section))
      end
    end

    context "as tutorado (self-enroll)" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "enrolls themselves" do
        expect {
          post section_enrollments_path(section)
        }.to change(Enrollment, :count).by(1)
        expect(Enrollment.last.user).to eq(tutorado_user)
        expect(response).to redirect_to(section_path(section))
      end
    end

    context "when section is full" do
      before { admin_membership && sign_in_as(admin_user) }

      it "rejects enrollment" do
        section.max_students.times do
          student = create(:user)
          create(:membership, :tutorado, user: student, organization: organization)
          create(:enrollment, section: section, user: student)
        end

        new_student = create(:user)
        create(:membership, :tutorado, user: new_student, organization: organization)

        expect {
          post section_enrollments_path(section), params: {enrollment: {user_id: new_student.id}}
        }.not_to change(Enrollment, :count)
        expect(response).to redirect_to(section_path(section))
        expect(flash[:alert]).to eq("Section is full")
      end
    end

    context "duplicate enrollment (idempotent)" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "returns existing enrollment without creating a new one" do
        create(:enrollment, section: section, user: tutorado_user)

        expect {
          post section_enrollments_path(section)
        }.not_to change(Enrollment, :count)
        expect(response).to redirect_to(section_path(section))
      end
    end

    context "re-enrollment after withdrawal" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "re-enrolls a withdrawn student successfully" do
        enrollment = create(:enrollment, section: section, user: tutorado_user, status: "withdrawn")

        post section_enrollments_path(section)

        expect(enrollment.reload.status).to eq("active")
        expect(response).to redirect_to(section_path(section))
        expect(flash[:notice]).to eq("Enrolled successfully")
      end
    end

    context "admin enrolling user from another organization" do
      before { admin_membership && sign_in_as(admin_user) }

      it "rejects enrollment of user from another org" do
        other_org = create(:organization)
        other_user = create(:user)
        create(:membership, :tutorado, user: other_user, organization: other_org)

        post section_enrollments_path(section), params: {enrollment: {user_id: other_user.id}}
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "is not authorized" do
        expect {
          post section_enrollments_path(section)
        }.not_to change(Enrollment, :count)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "PATCH /enrollments/:id" do
    context "as tutorado (withdraw)" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "withdraws the enrollment" do
        enrollment = create(:enrollment, section: section, user: tutorado_user)
        patch enrollment_path(enrollment)
        expect(enrollment.reload.status).to eq("withdrawn")
        expect(response).to redirect_to(section_path(section))
      end
    end

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "can withdraw any enrollment" do
        enrollment = create(:enrollment, section: section, user: tutorado_user)
        patch enrollment_path(enrollment)
        expect(enrollment.reload.status).to eq("withdrawn")
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "is not authorized" do
        enrollment = create(:enrollment, section: section, user: tutorado_user)
        patch enrollment_path(enrollment)
        expect(enrollment.reload.status).to eq("active")
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "DELETE /enrollments/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "destroys the enrollment" do
        enrollment = create(:enrollment, section: section, user: tutorado_user)
        expect {
          delete enrollment_path(enrollment)
        }.to change(Enrollment, :count).by(-1)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "is not authorized" do
        enrollment = create(:enrollment, section: section, user: tutorado_user)
        expect {
          delete enrollment_path(enrollment)
        }.not_to change(Enrollment, :count)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "capacity enforcement with concurrent requests" do
    before { admin_membership && sign_in_as(admin_user) }

    it "does not exceed max_students even with rapid sequential requests" do
      small_section = create(:section, course: course, tutor: tutor_user, max_students: 1)

      student1 = create(:user)
      create(:membership, :tutorado, user: student1, organization: organization)
      student2 = create(:user)
      create(:membership, :tutorado, user: student2, organization: organization)

      post section_enrollments_path(small_section), params: {enrollment: {user_id: student1.id}}
      expect(Enrollment.where(section: small_section).active.count).to eq(1)

      post section_enrollments_path(small_section), params: {enrollment: {user_id: student2.id}}
      expect(Enrollment.where(section: small_section).active.count).to eq(1)
      expect(flash[:alert]).to eq("Section is full")
    end
  end
end
