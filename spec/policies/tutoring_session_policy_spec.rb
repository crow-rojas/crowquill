# frozen_string_literal: true

require "rails_helper"

RSpec.describe TutoringSessionPolicy do
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, :admin, organization: organization) }
  let(:tutor_membership) { create(:membership, :tutor, organization: organization) }
  let(:tutorado_membership) { create(:membership, :tutorado, organization: organization) }

  describe "#index?" do
    it "allows any member" do
      expect(described_class.new(admin_membership).index?).to be true
      expect(described_class.new(tutor_membership).index?).to be true
      expect(described_class.new(tutorado_membership).index?).to be true
    end
  end

  describe "#show?" do
    it "allows any member" do
      expect(described_class.new(admin_membership).show?).to be true
      expect(described_class.new(tutor_membership).show?).to be true
      expect(described_class.new(tutorado_membership).show?).to be true
    end
  end

  describe "#new?" do
    it "allows tutor or above" do
      expect(described_class.new(admin_membership).new?).to be true
      expect(described_class.new(tutor_membership).new?).to be true
    end

    it "denies tutorado" do
      expect(described_class.new(tutorado_membership).new?).to be false
    end
  end

  describe "#create?" do
    it "allows tutor or above" do
      expect(described_class.new(admin_membership).create?).to be true
      expect(described_class.new(tutor_membership).create?).to be true
    end

    it "denies tutorado" do
      expect(described_class.new(tutorado_membership).create?).to be false
    end
  end

  describe "#edit?" do
    it "allows tutor or above" do
      expect(described_class.new(admin_membership).edit?).to be true
      expect(described_class.new(tutor_membership).edit?).to be true
    end

    it "denies tutorado" do
      expect(described_class.new(tutorado_membership).edit?).to be false
    end
  end

  describe "#update?" do
    it "allows tutor or above" do
      expect(described_class.new(admin_membership).update?).to be true
      expect(described_class.new(tutor_membership).update?).to be true
    end

    it "denies tutorado" do
      expect(described_class.new(tutorado_membership).update?).to be false
    end
  end

  describe "#destroy?" do
    it "allows admin only" do
      expect(described_class.new(admin_membership).destroy?).to be true
    end

    it "denies tutor" do
      expect(described_class.new(tutor_membership).destroy?).to be false
    end

    it "denies tutorado" do
      expect(described_class.new(tutorado_membership).destroy?).to be false
    end
  end
end
