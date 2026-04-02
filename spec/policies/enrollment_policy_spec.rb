# frozen_string_literal: true

require "rails_helper"

RSpec.describe EnrollmentPolicy do
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, :admin, organization: organization) }
  let(:tutor_membership) { create(:membership, :tutor, organization: organization) }
  let(:tutorado_membership) { create(:membership, :tutorado, organization: organization) }

  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }
  let(:owned_section) { create(:section, course: course, tutor: tutor_membership.user) }

  let(:other_tutor_user) { create(:user) }
  let!(:other_tutor_membership) { create(:membership, :tutor, user: other_tutor_user, organization: organization) }
  let(:other_section) { create(:section, course: course, tutor: other_tutor_user) }

  before do
    create(:enrollment, section: owned_section, user: tutorado_membership.user)
  end

  describe "#index?" do
    it "allows admin to list enrollments for any section" do
      expect(described_class.new(admin_membership, owned_section).index?).to be true
      expect(described_class.new(admin_membership, other_section).index?).to be true
    end

    it "allows tutor to list enrollments only for owned sections" do
      expect(described_class.new(tutor_membership, owned_section).index?).to be true
      expect(described_class.new(tutor_membership, other_section).index?).to be false
    end

    it "allows tutorado to list enrollments only for enrolled sections" do
      expect(described_class.new(tutorado_membership, owned_section).index?).to be true
      expect(described_class.new(tutorado_membership, other_section).index?).to be false
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
