# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Courses", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
  let(:academic_period) { create(:academic_period, organization: organization) }

  let(:admin_user) { create(:user) }
  let(:admin_membership) { create(:membership, :admin, user: admin_user, organization: organization) }

  let(:tutor_user) { create(:user) }
  let(:tutor_membership) { create(:membership, :tutor, user: tutor_user, organization: organization) }

  let(:tutorado_user) { create(:user) }
  let(:tutorado_membership) { create(:membership, :tutorado, user: tutorado_user, organization: organization) }

  let(:other_tutor_user) { create(:user) }
  let(:other_tutor_membership) { create(:membership, :tutor, user: other_tutor_user, organization: organization) }

  let(:course) { create(:course, academic_period: academic_period) }

  describe "GET /academic_periods/:academic_period_id/courses" do
    before { course }

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get academic_period_courses_path(academic_period)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "returns success" do
        get academic_period_courses_path(academic_period)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "returns success" do
        get academic_period_courses_path(academic_period)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /courses/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get course_path(course)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "returns success" do
        get course_path(course)
        expect(response).to have_http_status(:success)
      end

      it "only includes sections assigned to the tutor" do
        own_section = create(:section, course: course, tutor: tutor_user)
        other_tutor_membership
        create(:section, course: course, tutor: other_tutor_user)

        get course_path(course)

        section_ids = inertia.props[:course]["sections"].map { |s| s["id"] }
        expect(section_ids).to contain_exactly(own_section.id)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "returns success" do
        get course_path(course)
        expect(response).to have_http_status(:success)
      end

      it "hides full sections when the student is not enrolled" do
        tutor_membership
        available_section = create(:section, course: course, tutor: tutor_user, max_students: 2)
        other_tutor_membership
        full_section = create(:section, course: course, tutor: other_tutor_user, max_students: 1)
        full_student = create(:user)
        create(:membership, :tutorado, user: full_student, organization: organization)
        create(:enrollment, section: full_section, user: full_student)

        get course_path(course)

        section_ids = inertia.props[:course]["sections"].map { |s| s["id"] }
        expect(section_ids).to include(available_section.id)
        expect(section_ids).not_to include(full_section.id)
      end
    end
  end

  describe "GET /academic_periods/:academic_period_id/courses/new" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get new_academic_period_course_path(academic_period)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "redirects (not authorized)" do
        get new_academic_period_course_path(academic_period)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "POST /academic_periods/:academic_period_id/courses" do
    let(:valid_params) { {course: {name: "Mathematics 101", description: "Intro to math"}} }

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "creates a course" do
        expect {
          post academic_period_courses_path(academic_period), params: valid_params
        }.to change(Course, :count).by(1)
      end

      it "redirects to the new course" do
        post academic_period_courses_path(academic_period), params: valid_params
        expect(response).to redirect_to(course_path(Course.last))
      end

      it "redirects back on validation failure" do
        post academic_period_courses_path(academic_period), params: {course: {name: ""}}
        expect(response).to redirect_to(new_academic_period_course_path(academic_period))
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        expect {
          post academic_period_courses_path(academic_period), params: valid_params
        }.not_to change(Course, :count)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "is not authorized" do
        expect {
          post academic_period_courses_path(academic_period), params: valid_params
        }.not_to change(Course, :count)
      end
    end
  end

  describe "GET /courses/:id/edit" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get edit_course_path(course)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "redirects (not authorized)" do
        get edit_course_path(course)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "PATCH /courses/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "updates the course" do
        patch course_path(course), params: {course: {name: "Updated Course"}}
        expect(course.reload.name).to eq("Updated Course")
        expect(response).to redirect_to(course_path(course))
      end

      it "redirects back on validation failure" do
        patch course_path(course), params: {course: {name: ""}}
        expect(response).to redirect_to(edit_course_path(course))
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        patch course_path(course), params: {course: {name: "Nope"}}
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "DELETE /courses/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "destroys the course" do
        course
        expect {
          delete course_path(course)
        }.to change(Course, :count).by(-1)
      end

      it "redirects to courses index" do
        delete course_path(course)
        expect(response).to redirect_to(academic_period_courses_path(course.academic_period))
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        course
        expect {
          delete course_path(course)
        }.not_to change(Course, :count)
      end
    end
  end
end
