# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AcademicPeriods", type: :request do
  let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }

  let(:admin_user) { create(:user) }
  let(:admin_membership) { create(:membership, :admin, user: admin_user, organization: organization) }

  let(:tutor_user) { create(:user) }
  let(:tutor_membership) { create(:membership, :tutor, user: tutor_user, organization: organization) }

  let(:tutorado_user) { create(:user) }
  let(:tutorado_membership) { create(:membership, :tutorado, user: tutorado_user, organization: organization) }

  let(:academic_period) { create(:academic_period, organization: organization) }

  describe "GET /academic_periods" do
    before { academic_period }

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get academic_periods_path
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "returns success" do
        get academic_periods_path
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "returns success" do
        get academic_periods_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /academic_periods/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get academic_period_path(academic_period)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "returns success" do
        get academic_period_path(academic_period)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /academic_periods/new" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get new_academic_period_path
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "redirects (not authorized)" do
        get new_academic_period_path
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "POST /academic_periods" do
    let(:valid_params) do
      {
        academic_period: {
          name: "2026 Semester 2",
          start_date: "2026-08-01",
          end_date: "2026-12-15",
          status: "draft"
        }
      }
    end

    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "creates an academic period" do
        expect {
          post academic_periods_path, params: valid_params
        }.to change(AcademicPeriod, :count).by(1)
      end

      it "redirects to the new academic period" do
        post academic_periods_path, params: valid_params
        expect(response).to redirect_to(academic_period_path(AcademicPeriod.last))
      end

      it "redirects back on validation failure" do
        post academic_periods_path, params: {academic_period: {name: ""}}
        expect(response).to redirect_to(new_academic_period_path)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        expect {
          post academic_periods_path, params: valid_params
        }.not_to change(AcademicPeriod, :count)
      end
    end

    context "as tutorado" do
      before { tutorado_membership && sign_in_as(tutorado_user) }

      it "is not authorized" do
        expect {
          post academic_periods_path, params: valid_params
        }.not_to change(AcademicPeriod, :count)
      end
    end
  end

  describe "GET /academic_periods/:id/edit" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "returns success" do
        get edit_academic_period_path(academic_period)
        expect(response).to have_http_status(:success)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "redirects (not authorized)" do
        get edit_academic_period_path(academic_period)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "PATCH /academic_periods/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "updates the academic period" do
        patch academic_period_path(academic_period), params: {academic_period: {name: "Updated Name"}}
        expect(academic_period.reload.name).to eq("Updated Name")
        expect(response).to redirect_to(academic_period_path(academic_period))
      end

      it "redirects back on validation failure" do
        patch academic_period_path(academic_period), params: {academic_period: {name: ""}}
        expect(response).to redirect_to(edit_academic_period_path(academic_period))
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        patch academic_period_path(academic_period), params: {academic_period: {name: "Nope"}}
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "DELETE /academic_periods/:id" do
    context "as admin" do
      before { admin_membership && sign_in_as(admin_user) }

      it "destroys the academic period" do
        academic_period # create it
        expect {
          delete academic_period_path(academic_period)
        }.to change(AcademicPeriod, :count).by(-1)
      end

      it "redirects to index" do
        delete academic_period_path(academic_period)
        expect(response).to redirect_to(academic_periods_path)
      end
    end

    context "as tutor" do
      before { tutor_membership && sign_in_as(tutor_user) }

      it "is not authorized" do
        academic_period
        expect {
          delete academic_period_path(academic_period)
        }.not_to change(AcademicPeriod, :count)
      end
    end
  end
end
