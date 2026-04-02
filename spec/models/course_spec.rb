# frozen_string_literal: true

require "rails_helper"

RSpec.describe Course do
  describe "validations" do
    subject { build(:course) }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:academic_period) }
    it { is_expected.to have_many(:sections).dependent(:destroy) }
    it { is_expected.to have_one(:organization).through(:academic_period) }
  end
end
