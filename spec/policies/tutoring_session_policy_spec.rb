# frozen_string_literal: true

require "rails_helper"

RSpec.describe TutoringSessionPolicy do
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

  let(:owned_session) { build(:tutoring_session, section: owned_section) }
  let(:other_session) { build(:tutoring_session, section: other_section) }

  before do
    create(:enrollment, section: owned_section, user: tutorado_membership.user)
  end

  describe "#index?" do
    it "allows admin for any section" do
      expect(described_class.new(admin_membership, owned_section).index?).to be true
      expect(described_class.new(admin_membership, other_section).index?).to be true
    end

    it "allows tutor only for owned section" do
      expect(described_class.new(tutor_membership, owned_section).index?).to be true
      expect(described_class.new(tutor_membership, other_section).index?).to be false
    end

    it "allows tutorado only for enrolled section" do
      expect(described_class.new(tutorado_membership, owned_section).index?).to be true
      expect(described_class.new(tutorado_membership, other_section).index?).to be false
    end
  end

  describe "#show?" do
    it "allows admin for any session" do
      expect(described_class.new(admin_membership, owned_session).show?).to be true
      expect(described_class.new(admin_membership, other_session).show?).to be true
    end

    it "allows tutor only for owned session" do
      expect(described_class.new(tutor_membership, owned_session).show?).to be true
      expect(described_class.new(tutor_membership, other_session).show?).to be false
    end

    it "allows tutorado only for session in enrolled section" do
      expect(described_class.new(tutorado_membership, owned_session).show?).to be true
      expect(described_class.new(tutorado_membership, other_session).show?).to be false
    end
  end

  describe "#new?" do
    it "allows admin for any section" do
      expect(described_class.new(admin_membership, owned_section).new?).to be true
      expect(described_class.new(admin_membership, other_section).new?).to be true
    end

    it "allows tutor only for owned section" do
      expect(described_class.new(tutor_membership, owned_section).new?).to be true
      expect(described_class.new(tutor_membership, other_section).new?).to be false
    end

    it "denies tutorado" do
      expect(described_class.new(tutorado_membership, owned_section).new?).to be false
    end
  end

  describe "#create?" do
    it "allows admin for any session" do
      expect(described_class.new(admin_membership, owned_session).create?).to be true
      expect(described_class.new(admin_membership, other_session).create?).to be true
    end

    it "allows tutor for own section" do
      expect(described_class.new(tutor_membership, owned_session).create?).to be true
    end

    it "denies tutor for another tutor's section" do
      expect(described_class.new(tutor_membership, other_session).create?).to be false
    end

    it "denies tutorado" do
      expect(described_class.new(tutorado_membership, owned_session).create?).to be false
    end
  end

  describe "#edit?" do
    it "allows admin for any session" do
      expect(described_class.new(admin_membership, owned_session).edit?).to be true
      expect(described_class.new(admin_membership, other_session).edit?).to be true
    end

    it "allows tutor only for owned session" do
      expect(described_class.new(tutor_membership, owned_session).edit?).to be true
      expect(described_class.new(tutor_membership, other_session).edit?).to be false
    end

    it "denies tutorado" do
      expect(described_class.new(tutorado_membership, owned_session).edit?).to be false
    end
  end

  describe "#update?" do
    it "allows admin for any session" do
      expect(described_class.new(admin_membership, owned_session).update?).to be true
      expect(described_class.new(admin_membership, other_session).update?).to be true
    end

    it "allows tutor only for owned session" do
      expect(described_class.new(tutor_membership, owned_session).update?).to be true
      expect(described_class.new(tutor_membership, other_session).update?).to be false
    end

    it "denies tutorado" do
      expect(described_class.new(tutorado_membership, owned_session).update?).to be false
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
