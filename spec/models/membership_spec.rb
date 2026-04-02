# frozen_string_literal: true

require "rails_helper"

RSpec.describe Membership do
  describe "validations" do
    subject { build(:membership) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:organization_id) }

    it "validates role inclusion" do
      membership = build(:membership, role: "invalid")
      expect(membership).not_to be_valid
      expect(membership.errors[:role]).to be_present
    end

    it "accepts valid roles" do
      %w[admin tutor tutorado].each do |role|
        membership = build(:membership, role: role)
        expect(membership).to be_valid
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:organization) }
  end

  describe "uniqueness per user+org" do
    it "prevents duplicate membership for same user and organization" do
      user = create(:user)
      org = create(:organization)
      create(:membership, user: user, organization: org, role: "tutorado")

      duplicate = build(:membership, user: user, organization: org, role: "admin")
      expect(duplicate).not_to be_valid
    end

    it "allows same user in different organizations" do
      user = create(:user)
      org1 = create(:organization)
      org2 = create(:organization)

      create(:membership, user: user, organization: org1, role: "tutorado")
      membership2 = build(:membership, user: user, organization: org2, role: "admin")
      expect(membership2).to be_valid
    end
  end

  describe "role helpers" do
    it "#admin_or_above? returns true for admin" do
      membership = build(:membership, :admin)
      expect(membership.admin_or_above?).to be true
    end

    it "#admin_or_above? returns false for tutor" do
      membership = build(:membership, :tutor)
      expect(membership.admin_or_above?).to be false
    end

    it "#tutor_or_above? returns true for admin" do
      membership = build(:membership, :admin)
      expect(membership.tutor_or_above?).to be true
    end

    it "#tutor_or_above? returns true for tutor" do
      membership = build(:membership, :tutor)
      expect(membership.tutor_or_above?).to be true
    end

    it "#tutor_or_above? returns false for tutorado" do
      membership = build(:membership, :tutorado)
      expect(membership.tutor_or_above?).to be false
    end
  end

  describe "string-backed enum" do
    it "stores role as string in database" do
      membership = create(:membership, :admin)
      membership.reload
      expect(membership.role).to eq("admin")
      expect(membership.admin?).to be true
    end
  end
end
