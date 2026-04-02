# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExerciseSetPolicy do
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, :admin, organization: organization) }
  let(:tutor_membership) { create(:membership, :tutor, organization: organization) }
  let(:tutorado_membership) { create(:membership, :tutorado, organization: organization) }

  describe "#index?" do
    it "allows any member to list exercises" do
      [admin_membership, tutor_membership, tutorado_membership].each do |membership|
        expect(described_class.new(membership).index?).to be true
      end
    end
  end

  describe "#show?" do
    it "allows any member to view exercises" do
      [admin_membership, tutor_membership, tutorado_membership].each do |membership|
        expect(described_class.new(membership).show?).to be true
      end
    end
  end

  describe "#create?" do
    it "allows admin to create exercises" do
      expect(described_class.new(admin_membership).create?).to be true
    end

    it "denies tutor from creating exercises" do
      expect(described_class.new(tutor_membership).create?).to be false
    end

    it "denies tutorado from creating exercises" do
      expect(described_class.new(tutorado_membership).create?).to be false
    end
  end

  describe "#update?" do
    it "allows admin to update exercises" do
      expect(described_class.new(admin_membership).update?).to be true
    end

    it "denies non-admins from updating exercises" do
      expect(described_class.new(tutor_membership).update?).to be false
      expect(described_class.new(tutorado_membership).update?).to be false
    end
  end

  describe "#destroy?" do
    it "allows admin to destroy exercises" do
      expect(described_class.new(admin_membership).destroy?).to be true
    end

    it "denies non-admins from destroying exercises" do
      expect(described_class.new(tutor_membership).destroy?).to be false
    end
  end
end
