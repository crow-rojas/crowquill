# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
  let(:academic_period) { create(:academic_period, organization: organization, status: "active") }
  let(:course) { create(:course, academic_period: academic_period) }

  let(:admin_user) { create(:user) }
  let(:admin_membership) { create(:membership, :admin, user: admin_user, organization: organization) }

  let(:tutor_user) { create(:user) }
  let(:tutor_membership) { create(:membership, :tutor, user: tutor_user, organization: organization) }

  let(:tutorado_user) { create(:user) }
  let(:tutorado_membership) { create(:membership, :tutorado, user: tutorado_user, organization: organization) }

  describe "GET /dashboard" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get dashboard_path
        expect(response).to redirect_to(sign_in_path)
      end
    end

    context "when user has no membership" do
      let(:user_without_membership) { create(:user) }

      before { sign_in_as(user_without_membership) }

      it "redirects to onboarding" do
        get dashboard_path
        expect(response).to redirect_to(onboarding_path)
      end
    end

    context "as admin" do
      before do
        admin_membership
        sign_in_as(admin_user)
      end

      it "returns success" do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end

      it "includes admin dashboard props" do
        academic_period
        get dashboard_path

        expect(inertia.props[:role]).to eq("admin")
        expect(inertia.props[:total_students]).to be_a(Integer)
        expect(inertia.props[:total_tutors]).to be_a(Integer)
        expect(inertia.props[:active_sections]).to be_a(Integer)
      end

      it "includes active period info" do
        academic_period
        get dashboard_path

        expect(inertia.props[:active_period]).to be_present
        expect(inertia.props[:active_period]["year"]).to eq(academic_period.year)
        expect(inertia.props[:active_period]["semester"]).to eq(academic_period.semester)
      end

      it "counts students and tutors correctly" do
        tutor_membership
        tutorado_membership
        create(:membership, :tutorado, organization: organization)

        get dashboard_path

        expect(inertia.props[:total_students]).to eq(2)
        expect(inertia.props[:total_tutors]).to eq(1)
      end

      it "includes recent sessions" do
        tutor_membership
        section = create(:section, course: course, tutor: tutor_user)
        create(:tutoring_session, section: section, date: Date.current)

        get dashboard_path

        expect(inertia.props[:recent_sessions]).to be_an(Array)
        expect(inertia.props[:recent_sessions].length).to eq(1)
      end
    end

    context "as tutor" do
      before do
        tutor_membership
        sign_in_as(tutor_user)
      end

      it "returns success" do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end

      it "includes tutor dashboard props" do
        get dashboard_path

        expect(inertia.props[:role]).to eq("tutor")
        expect(inertia.props[:my_sections]).to be_an(Array)
        expect(inertia.props[:upcoming_sessions]).to be_an(Array)
      end

      it "includes only the tutor's sections" do
        my_section = create(:section, course: course, tutor: tutor_user)
        other_tutor = create(:user)
        create(:membership, :tutor, user: other_tutor, organization: organization)
        create(:section, course: course, tutor: other_tutor)

        get dashboard_path

        section_ids = inertia.props[:my_sections].map { |s| s["id"] }
        expect(section_ids).to contain_exactly(my_section.id)
      end

      it "includes upcoming sessions for tutor's sections" do
        section = create(:section, course: course, tutor: tutor_user)
        create(:tutoring_session, section: section, date: Date.current + 1)

        get dashboard_path

        expect(inertia.props[:upcoming_sessions].length).to eq(1)
      end
    end

    context "as tutorado" do
      before do
        tutorado_membership
        sign_in_as(tutorado_user)
      end

      it "returns success" do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end

      it "includes tutorado dashboard props" do
        get dashboard_path

        expect(inertia.props[:role]).to eq("tutorado")
        expect(inertia.props[:my_sections]).to be_an(Array)
        expect(inertia.props[:upcoming_sessions]).to be_an(Array)
        expect(inertia.props[:recent_exercises]).to be_an(Array)
      end

      it "includes enrolled sections" do
        tutor_membership
        section = create(:section, course: course, tutor: tutor_user)
        create(:enrollment, section: section, user: tutorado_user, status: "active")

        get dashboard_path

        section_ids = inertia.props[:my_sections].map { |s| s["id"] }
        expect(section_ids).to contain_exactly(section.id)
      end

      it "includes upcoming sessions for enrolled sections" do
        tutor_membership
        section = create(:section, course: course, tutor: tutor_user)
        create(:enrollment, section: section, user: tutorado_user, status: "active")
        create(:tutoring_session, section: section, date: Date.current + 1)

        get dashboard_path

        expect(inertia.props[:upcoming_sessions].length).to eq(1)
      end

      it "includes published exercises for enrolled courses" do
        tutor_membership
        section = create(:section, course: course, tutor: tutor_user)
        create(:enrollment, section: section, user: tutorado_user, status: "active")
        create(:exercise_set, :published, course: course)
        create(:exercise_set, course: course) # unpublished, should not appear

        get dashboard_path

        expect(inertia.props[:recent_exercises].length).to eq(1)
      end

      it "does not include sections from withdrawn enrollments" do
        tutor_membership
        section = create(:section, course: course, tutor: tutor_user)
        create(:enrollment, section: section, user: tutorado_user, status: "withdrawn")

        get dashboard_path

        expect(inertia.props[:my_sections]).to be_empty
      end
    end
  end
end
