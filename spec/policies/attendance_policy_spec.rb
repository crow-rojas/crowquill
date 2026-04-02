# frozen_string_literal: true

require "rails_helper"

RSpec.describe AttendancePolicy do
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, :admin, organization: organization) }
  let(:tutor_membership) { create(:membership, :tutor, organization: organization) }
  let(:tutorado_membership) { create(:membership, :tutorado, organization: organization) }
  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }
  let(:owned_section) { create(:section, course: course, tutor: tutor_membership.user) }
  let(:owned_session) { create(:tutoring_session, section: owned_section) }

  let(:other_tutor_user) { create(:user) }
  let!(:other_tutor_membership) { create(:membership, :tutor, user: other_tutor_user, organization: organization) }
  let(:other_section) { create(:section, course: course, tutor: other_tutor_user) }
  let(:other_session) { create(:tutoring_session, section: other_section) }

  describe "#index?" do
    it "allows admin to view attendance" do
      expect(described_class.new(admin_membership, owned_session).index?).to be true
    end

    it "allows tutor to view attendance for owned section" do
      expect(described_class.new(tutor_membership, owned_session).index?).to be true
    end

    it "denies tutor from viewing attendance for another tutor section" do
      expect(described_class.new(tutor_membership, other_session).index?).to be false
    end

    it "denies tutor when no section context is provided" do
      expect(described_class.new(tutor_membership).index?).to be false
    end

    it "denies tutorado from viewing attendance" do
      expect(described_class.new(tutorado_membership, owned_session).index?).to be false
    end
  end

  describe "#create?" do
    it "allows admin to create attendance" do
      expect(described_class.new(admin_membership, owned_session).create?).to be true
    end

    it "allows tutor for owned section" do
      expect(described_class.new(tutor_membership, owned_session).create?).to be true
    end

    it "denies tutor for unowned section" do
      expect(described_class.new(tutor_membership, other_session).create?).to be false
    end

    it "denies tutorado from creating attendance" do
      expect(described_class.new(tutorado_membership, owned_session).create?).to be false
    end
  end

  describe "#update?" do
    it "allows admin to update attendance" do
      expect(described_class.new(admin_membership, owned_session).update?).to be true
    end

    it "allows tutor to update attendance for owned section" do
      expect(described_class.new(tutor_membership, owned_session).update?).to be true
    end

    it "denies tutor from updating attendance for unowned section" do
      expect(described_class.new(tutor_membership, other_session).update?).to be false
    end

    it "denies tutorado from updating attendance" do
      expect(described_class.new(tutorado_membership, owned_session).update?).to be false
    end
  end

  describe "#view_statistics?" do
    it "allows admin to view statistics" do
      expect(described_class.new(admin_membership).view_statistics?).to be true
    end

    it "denies tutor from viewing statistics" do
      expect(described_class.new(tutor_membership).view_statistics?).to be false
    end

    it "denies tutorado from viewing statistics" do
      expect(described_class.new(tutorado_membership).view_statistics?).to be false
    end
  end
end
