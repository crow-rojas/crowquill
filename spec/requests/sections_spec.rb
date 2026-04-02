# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sections", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }

  let(:admin_user) { create(:user) }
  let(:admin_membership) { create(:membership, :admin, user: admin_user, organization: organization) }

  let(:tutor_user) { create(:user) }
  let(:tutor_membership) { create(:membership, :tutor, user: tutor_user, organization: organization) }

  let(:tutorado_user) { create(:user) }
  let(:tutorado_membership) { create(:membership, :tutorado, user: tutorado_user, organization: organization) }

  let(:section) { create(:section, course: course, tutor: tutor_user) }
  let(:other_tutor_user) { create(:user) }
  let(:other_tutor_membership) { create(:membership, :tutor, user: other_tutor_user, organization: organization) }
  let(:other_section) { create(:section, course: course, tutor: other_tutor_user) }

  before do
    # Ensure tutor_membership exists so tutor_user is valid for sections
    tutor_membership
  end

  describe "GET /courses/:course_id/sections" do
    before { section }

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get course_sections_path(course)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "returns success" do
        get course_sections_path(course)
        expect(response).to have_http_status(:success)
      end

      it "returns only owned sections" do
        other_tutor_membership
        other_section

        get course_sections_path(course)

        section_ids = inertia.props[:sections].map { |s| s["id"] }
        expect(section_ids).to contain_exactly(section.id)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "returns success" do
        get course_sections_path(course)
        expect(response).to have_http_status(:success)
      end

      it "hides full sections when the user is not enrolled" do
        other_tutor_membership
        full_section = create(:section, course: course, tutor: other_tutor_user, max_students: 1)
        full_student = create(:user)
        create(:membership, :tutorado, user: full_student, organization: organization)
        create(:enrollment, section: full_section, user: full_student)

        get course_sections_path(course)

        section_ids = inertia.props[:sections].map { |s| s["id"] }
        expect(section_ids).to include(section.id)
        expect(section_ids).not_to include(full_section.id)
      end
    end
  end

  describe "GET /sections/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get section_path(section)
        expect(response).to have_http_status(:success)
      end

      it "includes tutor info in response" do
        get section_path(section)
        expect(response).to have_http_status(:success)
      end

      it "includes tutoring session capabilities" do
        get section_path(section)

        expect(response).to have_http_status(:success)
        expect(inertia.props[:can_view_sessions]).to be true
        expect(inertia.props[:can_create_session]).to be true
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "returns success" do
        get section_path(section)

        expect(response).to have_http_status(:success)
        expect(inertia.props[:can_view_sessions]).to be true
        expect(inertia.props[:can_create_session]).to be true
      end
    end

    context "as tutor viewing another tutor section" do
      before do
        other_tutor_membership
        sign_in_as(tutor_user)
      end

      it "is not authorized" do
        get section_path(other_section)

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "as tutorado enrolled in section" do
      before do
        tutorado_membership
        create(:enrollment, section: section, user: tutorado_user)
        sign_in_as(tutorado_user)
      end

      it "returns success and allows viewing enrollments" do
        get section_path(section)

        expect(response).to have_http_status(:success)
        expect(inertia.props[:can_view_enrollments]).to be true
        expect(inertia.props[:can_view_sessions]).to be true
        expect(inertia.props[:can_create_session]).to be false
      end
    end

    context "as tutorado viewing available section" do
      before do
        tutorado_membership
        sign_in_as(tutorado_user)
      end

      it "returns success but cannot view enrollments list" do
        get section_path(section)

        expect(response).to have_http_status(:success)
        expect(inertia.props[:can_view_enrollments]).to be false
        expect(inertia.props[:can_view_sessions]).to be false
        expect(inertia.props[:can_create_session]).to be false
      end
    end

    context "as tutorado viewing full section without enrollment" do
      before do
        tutorado_membership
        full_student = create(:user)
        create(:membership, :tutorado, user: full_student, organization: organization)
        section.update!(max_students: 1)
        create(:enrollment, section: section, user: full_student)
        sign_in_as(tutorado_user)
      end

      it "is not authorized" do
        get section_path(section)

        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "GET /courses/:course_id/sections/new" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get new_course_section_path(course)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "redirects (not authorized)" do
        get new_course_section_path(course)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "POST /courses/:course_id/sections" do
    let(:valid_params) do
      {
        section: {
          name: "Section A",
          tutor_id: tutor_user.id,
          max_students: 15,
          schedule: {monday: {start: "09:00", end: "10:30"}}
        }
      }
    end

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "creates a section" do
        expect {
          post course_sections_path(course), params: valid_params
        }.to change(Section, :count).by(1)
      end

      it "redirects to the new section" do
        post course_sections_path(course), params: valid_params
        expect(response).to redirect_to(section_path(Section.last))
      end

      it "redirects back on validation failure" do
        post course_sections_path(course), params: {section: {name: "", tutor_id: tutor_user.id}}
        expect(response).to redirect_to(new_course_section_path(course))
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "is not authorized" do
        expect {
          post course_sections_path(course), params: valid_params
        }.not_to change(Section, :count)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "is not authorized" do
        expect {
          post course_sections_path(course), params: valid_params
        }.not_to change(Section, :count)
      end
    end
  end

  describe "GET /sections/:id/edit" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get edit_section_path(section)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "redirects (not authorized)" do
        get edit_section_path(section)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "PATCH /sections/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "updates the section" do
        patch section_path(section), params: {section: {name: "Updated Section"}}
        expect(section.reload.name).to eq("Updated Section")
        expect(response).to redirect_to(section_path(section))
      end

      it "redirects back on validation failure" do
        patch section_path(section), params: {section: {name: ""}}
        expect(response).to redirect_to(edit_section_path(section))
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "is not authorized" do
        patch section_path(section), params: {section: {name: "Nope"}}
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "DELETE /sections/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "destroys the section" do
        section
        expect {
          delete section_path(section)
        }.to change(Section, :count).by(-1)
      end

      it "redirects to sections index" do
        course_ref = section.course
        delete section_path(section)
        expect(response).to redirect_to(course_sections_path(course_ref))
      end
    end

    context "as tutor" do
      before { sign_in_as(tutor_user) }

      it "is not authorized" do
        section
        expect {
          delete section_path(section)
        }.not_to change(Section, :count)
      end
    end
  end
end
