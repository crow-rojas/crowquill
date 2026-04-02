# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ExerciseSets", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }

  let(:admin_user) { create(:user) }
  let(:admin_membership) { create(:membership, :admin, user: admin_user, organization: organization) }

  let(:tutor_user) { create(:user) }
  let(:tutor_membership) { create(:membership, :tutor, user: tutor_user, organization: organization) }

  let(:tutorado_user) { create(:user) }
  let(:tutorado_membership) { create(:membership, :tutorado, user: tutorado_user, organization: organization) }

  let(:exercise_set) { create(:exercise_set, course: course) }
  let(:published_exercise_set) { create(:exercise_set, :published, course: course) }

  describe "GET /courses/:course_id/exercise_sets" do
    before { published_exercise_set && exercise_set }

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get course_exercise_sets_path(course)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "returns success" do
        get course_exercise_sets_path(course)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "returns success" do
        get course_exercise_sets_path(course)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /exercise_sets/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "can view a draft exercise" do
        get exercise_set_path(exercise_set)
        expect(response).to have_http_status(:success)
      end

      it "can view a published exercise" do
        get exercise_set_path(published_exercise_set)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "can view a published exercise" do
        get exercise_set_path(published_exercise_set)
        expect(response).to have_http_status(:success)
      end

      it "cannot view a draft exercise" do
        get exercise_set_path(exercise_set)
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "can view a published exercise" do
        get exercise_set_path(published_exercise_set)
        expect(response).to have_http_status(:success)
      end

      it "cannot view a draft exercise" do
        get exercise_set_path(exercise_set)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "GET /courses/:course_id/exercise_sets/new" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get new_course_exercise_set_path(course)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "redirects (not authorized)" do
        get new_course_exercise_set_path(course)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "POST /courses/:course_id/exercise_sets" do
    let(:valid_params) do
      {exercise_set: {title: "Week 1 Exercises", week_number: 1, content: "# Exercises\n\nSolve $x=1$"}}
    end

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "creates an exercise set" do
        expect {
          post course_exercise_sets_path(course), params: valid_params
        }.to change(ExerciseSet, :count).by(1)
      end

      it "redirects to the new exercise set" do
        post course_exercise_sets_path(course), params: valid_params
        expect(response).to redirect_to(exercise_set_path(ExerciseSet.last))
      end

      it "redirects back on validation failure" do
        post course_exercise_sets_path(course), params: {exercise_set: {title: "", week_number: 0, content: ""}}
        expect(response).to redirect_to(new_course_exercise_set_path(course))
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        expect {
          post course_exercise_sets_path(course), params: valid_params
        }.not_to change(ExerciseSet, :count)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "is not authorized" do
        expect {
          post course_exercise_sets_path(course), params: valid_params
        }.not_to change(ExerciseSet, :count)
      end
    end
  end

  describe "GET /exercise_sets/:id/edit" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get edit_exercise_set_path(exercise_set)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "redirects (not authorized)" do
        get edit_exercise_set_path(exercise_set)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "PATCH /exercise_sets/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "updates the exercise set" do
        patch exercise_set_path(exercise_set), params: {exercise_set: {title: "Updated Title"}}
        expect(exercise_set.reload.title).to eq("Updated Title")
        expect(response).to redirect_to(exercise_set_path(exercise_set))
      end

      it "redirects back on validation failure" do
        patch exercise_set_path(exercise_set), params: {exercise_set: {title: ""}}
        expect(response).to redirect_to(edit_exercise_set_path(exercise_set))
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        patch exercise_set_path(exercise_set), params: {exercise_set: {title: "Nope"}}
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "DELETE /exercise_sets/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "destroys the exercise set" do
        exercise_set
        expect {
          delete exercise_set_path(exercise_set)
        }.to change(ExerciseSet, :count).by(-1)
      end

      it "redirects to exercise sets index" do
        delete exercise_set_path(exercise_set)
        expect(response).to redirect_to(course_exercise_sets_path(course))
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        exercise_set
        expect {
          delete exercise_set_path(exercise_set)
        }.not_to change(ExerciseSet, :count)
      end
    end
  end

  describe "PATCH /exercise_sets/:id/publish" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "publishes the exercise set" do
        patch publish_exercise_set_path(exercise_set)
        expect(exercise_set.reload.published).to be(true)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        patch publish_exercise_set_path(exercise_set)
        expect(exercise_set.reload.published).to be(false)
      end
    end
  end

  describe "PATCH /exercise_sets/:id/unpublish" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "unpublishes the exercise set" do
        patch unpublish_exercise_set_path(published_exercise_set)
        expect(published_exercise_set.reload.published).to be(false)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        patch unpublish_exercise_set_path(published_exercise_set)
        expect(published_exercise_set.reload.published).to be(true)
      end
    end
  end
end
