# frozen_string_literal: true

require "rails_helper"

RSpec.describe SectionPolicy do
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, :admin, organization: organization) }
  let(:tutor_membership) { create(:membership, :tutor, organization: organization) }
  let(:tutorado_membership) { create(:membership, :tutorado, organization: organization) }

  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }
  let(:owned_section) { create(:section, course: course, tutor: tutor_membership.user, max_students: 2) }

  let(:other_tutor_user) { create(:user) }
  let!(:other_tutor_membership) { create(:membership, :tutor, user: other_tutor_user, organization: organization) }
  let(:other_section) { create(:section, course: course, tutor: other_tutor_user, max_students: 2) }

  before do
    create(:enrollment, section: owned_section, user: tutorado_membership.user)
  end

  describe "#index?" do
    it "allows any member to list sections" do
      [admin_membership, tutor_membership, tutorado_membership].each do |membership|
        policy = described_class.new(membership)
        expect(policy.index?).to be true
      end
    end
  end

  describe "#show?" do
    it "allows admin to view any section" do
      expect(described_class.new(admin_membership, owned_section).show?).to be true
      expect(described_class.new(admin_membership, other_section).show?).to be true
    end

    it "allows tutor to view only their own sections" do
      expect(described_class.new(tutor_membership, owned_section).show?).to be true
      expect(described_class.new(tutor_membership, other_section).show?).to be false
    end

    it "allows tutorado to view enrolled sections" do
      expect(described_class.new(tutorado_membership, owned_section).show?).to be true
    end

    it "allows tutorado to view available sections" do
      expect(described_class.new(tutorado_membership, other_section).show?).to be true
    end

    it "denies tutorado for full sections when not enrolled" do
      full_section = create(:section, course: course, tutor: other_tutor_user, max_students: 1)
      full_student = create(:user)
      create(:membership, :tutorado, user: full_student, organization: organization)
      create(:enrollment, section: full_section, user: full_student)

      expect(described_class.new(tutorado_membership, full_section).show?).to be false
    end
  end

  describe "#create?" do
    it "allows admin to create sections" do
      expect(described_class.new(admin_membership).create?).to be true
    end

    it "denies tutor from creating sections" do
      expect(described_class.new(tutor_membership).create?).to be false
    end

    it "denies tutorado from creating sections" do
      expect(described_class.new(tutorado_membership).create?).to be false
    end
  end

  describe "#update?" do
    it "allows admin to update sections" do
      expect(described_class.new(admin_membership).update?).to be true
    end

    it "denies tutor from updating sections" do
      expect(described_class.new(tutor_membership).update?).to be false
    end
  end

  describe "#destroy?" do
    it "allows admin to destroy sections" do
      expect(described_class.new(admin_membership).destroy?).to be true
    end

    it "denies tutor from destroying sections" do
      expect(described_class.new(tutor_membership).destroy?).to be false
    end
  end

  describe "#take_attendance?" do
    let(:tutor_user) { tutor_membership.user }
    let(:section) { double("Section", tutor_id: tutor_user.id) }

    it "allows admin regardless of section ownership" do
      expect(described_class.new(admin_membership, section).take_attendance?).to be true
    end

    it "allows tutor for their own section" do
      expect(described_class.new(tutor_membership, section).take_attendance?).to be true
    end

    it "denies tutor for another tutor's section" do
      other_section = double("Section", tutor_id: -1)
      expect(described_class.new(tutor_membership, other_section).take_attendance?).to be false
    end

    it "denies tutorado from taking attendance" do
      expect(described_class.new(tutorado_membership, section).take_attendance?).to be false
    end
  end
end
