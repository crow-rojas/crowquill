# frozen_string_literal: true

require "rails_helper"

RSpec.describe TutoringSession do
  let(:organization) { create(:organization) }
  let(:academic_period) { create(:academic_period, organization: organization) }
  let(:course) { create(:course, academic_period: academic_period) }
  let(:tutor_user) { create(:user) }
  let(:section) { create(:section, course: course, tutor: tutor_user) }

  before do
    create(:membership, :tutor, user: tutor_user, organization: organization)
  end

  describe "validations" do
    subject { build(:tutoring_session, section: section) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:status) }

    it "validates status inclusion" do
      session = build(:tutoring_session, section: section, status: "invalid")
      expect(session).not_to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:section) }
    it { is_expected.to have_many(:attendances).dependent(:destroy) }
  end

  describe "scopes" do
    it ".upcoming returns sessions with date >= today ordered by date" do
      past = create(:tutoring_session, section: section, date: Date.yesterday)
      today = create(:tutoring_session, section: section, date: Date.current)
      future = create(:tutoring_session, section: section, date: Date.tomorrow)

      expect(described_class.upcoming).to eq([today, future])
      expect(described_class.upcoming).not_to include(past)
    end
  end

  describe "enum" do
    it "defines status enum" do
      session = build(:tutoring_session, section: section, status: "scheduled")
      expect(session).to be_scheduled

      session.status = "completed"
      expect(session).to be_completed

      session.status = "cancelled"
      expect(session).to be_cancelled
    end
  end
end
