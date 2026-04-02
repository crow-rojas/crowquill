# frozen_string_literal: true

require "rails_helper"

RSpec.describe Attendance do
  let(:organization) { create(:organization) }
  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }
  let(:tutor_user) { create(:user) }
  let(:section) { create(:section, course: course, tutor: tutor_user) }
  let(:student) { create(:user) }
  let(:enrollment) { create(:enrollment, section: section, user: student) }
  let(:tutoring_session) { create(:tutoring_session, section: section) }

  before do
    create(:membership, :tutor, user: tutor_user, organization: organization)
  end

  describe "validations" do
    subject { build(:attendance, tutoring_session: tutoring_session, enrollment: enrollment) }

    it { is_expected.to validate_presence_of(:status) }

    it "validates status inclusion" do
      attendance = build(:attendance, tutoring_session: tutoring_session, enrollment: enrollment, status: "invalid")
      expect(attendance).not_to be_valid
    end

    it "validates uniqueness of enrollment_id scoped to tutoring_session_id" do
      create(:attendance, tutoring_session: tutoring_session, enrollment: enrollment)
      duplicate = build(:attendance, tutoring_session: tutoring_session, enrollment: enrollment)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:enrollment_id]).to be_present
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:tutoring_session) }
    it { is_expected.to belong_to(:enrollment) }
  end

  describe "enum" do
    it "defines status enum" do
      attendance = build(:attendance, tutoring_session: tutoring_session, enrollment: enrollment, status: "present")
      expect(attendance).to be_present

      attendance.status = "absent"
      expect(attendance).to be_absent

      attendance.status = "justified"
      expect(attendance).to be_justified
    end
  end
end
