# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoursePolicy do
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, :admin, organization: organization) }
  let(:tutor_membership) { create(:membership, :tutor, organization: organization) }
  let(:tutorado_membership) { create(:membership, :tutorado, organization: organization) }

  describe "#index?" do
    it "allows any member to list courses" do
      [admin_membership, tutor_membership, tutorado_membership].each do |membership|
        policy = described_class.new(membership)
        expect(policy.index?).to be true
      end
    end
  end

  describe "#show?" do
    it "allows any member to view a course" do
      [admin_membership, tutor_membership, tutorado_membership].each do |membership|
        policy = described_class.new(membership)
        expect(policy.show?).to be true
      end
    end
  end

  describe "#create?" do
    it "allows admin to create courses" do
      expect(described_class.new(admin_membership).create?).to be true
    end

    it "denies tutor from creating courses" do
      expect(described_class.new(tutor_membership).create?).to be false
    end

    it "denies tutorado from creating courses" do
      expect(described_class.new(tutorado_membership).create?).to be false
    end
  end

  describe "#update?" do
    it "allows admin to update courses" do
      expect(described_class.new(admin_membership).update?).to be true
    end

    it "denies tutor from updating courses" do
      expect(described_class.new(tutor_membership).update?).to be false
    end
  end

  describe "#destroy?" do
    it "allows admin to destroy courses" do
      expect(described_class.new(admin_membership).destroy?).to be true
    end

    it "denies tutor from destroying courses" do
      expect(described_class.new(tutor_membership).destroy?).to be false
    end
  end
end
