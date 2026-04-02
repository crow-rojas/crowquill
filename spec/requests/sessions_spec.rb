# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /new" do
    it "returns http success" do
      get sign_in_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /sign_in" do
    context "with valid credentials" do
      it "redirects to the dashboard url" do
        post sign_in_url, params: {email: user.email, password: "Secret1*3*5*"}
        expect(response).to redirect_to(dashboard_url)
      end

      it "allows dashboard access when user has a membership" do
        org = create(:organization, slug: "pimu-uc")
        create(:membership, user: user, organization: org, role: "tutorado")

        post sign_in_url, params: {email: user.email, password: "Secret1*3*5*"}
        follow_redirect!

        get dashboard_url
        expect(response).to have_http_status(:success)
      end

      it "redirects to onboarding when user has no membership" do
        post sign_in_url, params: {email: user.email, password: "Secret1*3*5*"}
        follow_redirect!

        get dashboard_url
        expect(response).to redirect_to(onboarding_url)
      end
    end

    context "with invalid credentials" do
      before { sign_out }

      it "redirects to the sign in url with an alert" do
        post sign_in_url, params: {email: user.email, password: "SecretWrong1*3"}
        expect(response).to redirect_to(sign_in_url)
        expect(flash[:alert]).to eq(I18n.t("flash.sessions.invalid_credentials", locale: :en))

        get dashboard_url
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end

  describe "DELETE /sign_out" do
    before { sign_in_as user }

    it "signs out the user and redirects to the sign in url" do
      delete session_url(user.sessions.last)
      expect(response).to redirect_to(settings_sessions_url)

      follow_redirect!
      expect(response).to redirect_to(sign_in_url)
    end
  end

  describe "POST /dev/switch_user" do
    let(:organization) { create(:organization, slug: ENV.fetch("DEFAULT_ORG_SLUG", "pimu-uc")) }
    let(:current_user) { create(:user) }
    let(:target_user) { create(:user) }
    let(:current_membership) { create(:membership, :admin, user: current_user, organization: organization) }
    let(:target_membership) { create(:membership, :tutor, user: target_user, organization: organization) }

    before do
      current_membership
      target_membership
      sign_in_as current_user
    end

    it "returns not found when feature flag is disabled" do
      post dev_switch_user_url, params: {membership_id: target_membership.id}

      expect(response).to have_http_status(:not_found)
    end

    context "when feature flag is enabled in development" do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("DEV_USER_SWITCH_ENABLED", false).and_return("true")
      end

      it "switches to the selected user from the same organization" do
        post dev_switch_user_url, params: {membership_id: target_membership.id, return_to: dashboard_path}

        expect(response).to redirect_to(dashboard_url)

        get dashboard_url
        expect(inertia.props[:role]).to eq("tutor")
      end

      it "allows switching to users from another organization" do
        outsider = create(:user)
        outsider_org = create(:organization)
        outsider_membership = create(:membership, :tutorado, user: outsider, organization: outsider_org)

        post dev_switch_user_url, params: {membership_id: outsider_membership.id, return_to: dashboard_path}

        expect(response).to redirect_to(dashboard_url)

        get dashboard_url
        expect(inertia.props[:role]).to eq("tutorado")
      end

      it "falls back to dashboard for unsafe return paths" do
        post dev_switch_user_url, params: {membership_id: target_membership.id, return_to: "https://example.com/malicious"}

        expect(response).to redirect_to(dashboard_url)
      end

      it "keeps safe internal return paths" do
        post dev_switch_user_url, params: {membership_id: target_membership.id, return_to: "/ai_conversations?page=2"}

        expect(response).to redirect_to("http://www.example.com/ai_conversations?page=2")
      end
    end
  end
end
