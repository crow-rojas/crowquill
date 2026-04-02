# frozen_string_literal: true

require "rails_helper"

RSpec.describe AcademicPeriod do
  describe "validations" do
    subject { build(:academic_period) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }

    it "validates end_date is after start_date" do
      period = build(:academic_period, start_date: Date.new(2026, 7, 1), end_date: Date.new(2026, 3, 1))
      expect(period).not_to be_valid
      expect(period.errors[:end_date]).to include("must be after start date")
    end

    it "validates end_date equals start_date is invalid" do
      period = build(:academic_period, start_date: Date.new(2026, 3, 1), end_date: Date.new(2026, 3, 1))
      expect(period).not_to be_valid
      expect(period.errors[:end_date]).to include("must be after start date")
    end

    it "validates status inclusion" do
      period = build(:academic_period)
      period.status = "invalid"
      expect(period).not_to be_valid
    end

    it "accepts valid statuses" do
      %w[draft active archived].each do |status|
        period = build(:academic_period, status: status)
        expect(period).to be_valid
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:courses).dependent(:destroy) }
  end

  describe "string-backed enum" do
    it "stores status as string in database" do
      period = create(:academic_period, :active)
      period.reload
      expect(period.status).to eq("active")
      expect(period.active?).to be true
    end
  end
end
