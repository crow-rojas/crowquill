# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization do
  describe "validations" do
    subject { build(:organization) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug).ignoring_case_sensitivity }
  end

  describe "associations" do
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:memberships) }
  end

  describe "slug normalization" do
    it "normalizes slug to lowercase" do
      org = build(:organization, slug: "PIMU-UC")
      org.validate
      expect(org.slug).to eq("pimu-uc")
    end

    it "strips whitespace from slug" do
      org = build(:organization, slug: "  pimu-uc  ")
      org.validate
      expect(org.slug).to eq("pimu-uc")
    end

    it "replaces invalid characters with hyphens" do
      org = build(:organization, slug: "pimu uc!")
      org.validate
      expect(org.slug).to eq("pimu-uc-")
    end
  end

  describe "settings" do
    it "defaults to empty hash" do
      org = create(:organization)
      expect(org.settings).to eq({})
    end

    it "stores JSONB settings" do
      org = create(:organization, settings: {"max_messages_per_hour" => 30})
      org.reload
      expect(org.settings["max_messages_per_hour"]).to eq(30)
    end
  end
end
