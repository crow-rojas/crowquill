# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TutoringSessions", type: :request do
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

  before do
    tutor_membership
  end

  describe "GET /sections/:section_id/tutoring_sessions" do
    before { create(:tutoring_session, section: section) }

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get section_tutoring_sessions_path(section)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "returns success" do
        get section_tutoring_sessions_path(section)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "returns success" do
        get section_tutoring_sessions_path(section)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /tutoring_sessions/:id" do
    let(:tutoring_session) { create(:tutoring_session, section: section) }

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "returns success" do
        get tutoring_session_path(tutoring_session)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /sections/:section_id/tutoring_sessions" do
    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "creates a tutoring session" do
        expect {
          post section_tutoring_sessions_path(section), params: {
            tutoring_session: {date: Date.tomorrow.to_s}
          }
        }.to change(TutoringSession, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "creates a tutoring session" do
        expect {
          post section_tutoring_sessions_path(section), params: {
            tutoring_session: {date: Date.tomorrow.to_s}
          }
        }.to change(TutoringSession, :count).by(1)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "is not authorized" do
        expect {
          post section_tutoring_sessions_path(section), params: {
            tutoring_session: {date: Date.tomorrow.to_s}
          }
        }.not_to change(TutoringSession, :count)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "PATCH /tutoring_sessions/:id" do
    let(:tutoring_session) { create(:tutoring_session, section: section) }

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "updates the session" do
        patch tutoring_session_path(tutoring_session), params: {
          tutoring_session: {status: "cancelled"}
        }
        expect(tutoring_session.reload.status).to eq("cancelled")
        expect(response).to have_http_status(:redirect)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "is not authorized" do
        patch tutoring_session_path(tutoring_session), params: {
          tutoring_session: {status: "cancelled"}
        }
        expect(tutoring_session.reload.status).to eq("scheduled")
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "DELETE /tutoring_sessions/:id" do
    let!(:tutoring_session) { create(:tutoring_session, section: section) }

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "destroys the session" do
        expect {
          delete tutoring_session_path(tutoring_session)
        }.to change(TutoringSession, :count).by(-1)
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "is not authorized" do
        expect {
          delete tutoring_session_path(tutoring_session)
        }.not_to change(TutoringSession, :count)
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "is not authorized" do
        expect {
          delete tutoring_session_path(tutoring_session)
        }.not_to change(TutoringSession, :count)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
