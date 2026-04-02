# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExerciseSet do
  describe "validations" do
    subject { build(:exercise_set) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_numericality_of(:week_number).is_greater_than(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:course) }
  end

  describe "scopes" do
    let!(:published_exercise) { create(:exercise_set, :published) }
    let!(:draft_exercise) { create(:exercise_set, published: false) }

    describe ".published" do
      it "returns only published exercises" do
        expect(described_class.published).to contain_exactly(published_exercise)
      end
    end

    describe ".ordered" do
      let!(:week3) { create(:exercise_set, week_number: 3) }
      let!(:week1) { create(:exercise_set, week_number: 1) }

      it "orders by week_number ascending" do
        result = described_class.where(id: [week3.id, week1.id]).ordered
        expect(result.first).to eq(week1)
      end
    end
  end
end
