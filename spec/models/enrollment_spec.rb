# frozen_string_literal: true

require "rails_helper"

RSpec.describe Enrollment do
  let(:organization) { create(:organization) }
  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }
  let(:tutor_user) { create(:user) }
  let(:section) { create(:section, course: course, tutor: tutor_user) }

  before do
    create(:membership, :tutor, user: tutor_user, organization: organization)
  end

  describe "validations" do
    subject { build(:enrollment, section: section) }

    it { is_expected.to validate_presence_of(:status) }

    it "validates uniqueness of user_id scoped to section_id" do
      enrollment = create(:enrollment, section: section)
      duplicate = build(:enrollment, section: section, user: enrollment.user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it "validates status inclusion" do
      enrollment = build(:enrollment, section: section, status: "invalid")
      expect(enrollment).not_to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:section) }
    it { is_expected.to belong_to(:user) }
  end

  describe "scopes" do
    it ".active returns only active enrollments" do
      active = create(:enrollment, section: section, status: "active")
      create(:enrollment, section: section, status: "withdrawn")

      expect(described_class.active).to eq([active])
    end
  end

  describe "enum" do
    it "defines status enum" do
      enrollment = build(:enrollment, section: section, status: "active")
      expect(enrollment).to be_active

      enrollment.status = "withdrawn"
      expect(enrollment).to be_withdrawn
    end
  end
end
