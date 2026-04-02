# frozen_string_literal: true

require "rails_helper"

RSpec.describe EnrollmentPolicy do
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, :admin, organization: organization) }
  let(:tutor_membership) { create(:membership, :tutor, organization: organization) }
  let(:tutorado_membership) { create(:membership, :tutorado, organization: organization) }

  describe "#index?" do
    it "allows any member to list enrollments" do
      [admin_membership, tutor_membership, tutorado_membership].each do |membership|
        policy = described_class.new(membership)
        expect(policy.index?).to be true
      end
    end
  end

  describe "#create?" do
    it "allows admin to create enrollments" do
      expect(described_class.new(admin_membership).create?).to be true
    end

    it "allows tutorado to create enrollments" do
      expect(described_class.new(tutorado_membership).create?).to be true
    end

    it "denies tutor from creating enrollments" do
      expect(described_class.new(tutor_membership).create?).to be false
    end
  end

  describe "#update?" do
    let(:tutorado_user) { tutorado_membership.user }
    let(:enrollment) { double("Enrollment", user_id: tutorado_user.id) }

    it "allows admin to update any enrollment" do
      expect(described_class.new(admin_membership, enrollment).update?).to be true
    end

    it "allows tutorado to update their own enrollment" do
      expect(described_class.new(tutorado_membership, enrollment).update?).to be true
    end

    it "denies tutorado from updating another's enrollment" do
      other_enrollment = double("Enrollment", user_id: -1)
      expect(described_class.new(tutorado_membership, other_enrollment).update?).to be false
    end

    it "denies tutor from updating enrollments" do
      expect(described_class.new(tutor_membership, enrollment).update?).to be false
    end
  end

  describe "#destroy?" do
    it "allows admin to destroy enrollments" do
      expect(described_class.new(admin_membership).destroy?).to be true
    end

    it "denies tutorado from destroying enrollments" do
      expect(described_class.new(tutorado_membership).destroy?).to be false
    end

    it "denies tutor from destroying enrollments" do
      expect(described_class.new(tutor_membership).destroy?).to be false
    end
  end
end
