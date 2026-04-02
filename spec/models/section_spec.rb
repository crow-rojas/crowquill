# frozen_string_literal: true

require "rails_helper"

RSpec.describe Section do
  describe "validations" do
    subject { build(:section) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:max_students).is_greater_than(0) }

    it "is invalid with max_students of 0" do
      section = build(:section, max_students: 0)
      expect(section).not_to be_valid
      expect(section.errors[:max_students]).to be_present
    end

    it "is invalid with negative max_students" do
      section = build(:section, max_students: -1)
      expect(section).not_to be_valid
    end

    context "tutor role validation" do
      let(:organization) { create(:organization) }
      let(:academic_period) { create(:academic_period, organization: organization) }
      let(:course) { create(:course, academic_period: academic_period) }

      it "is valid when tutor has tutor role" do
        tutor_user = create(:user)
        create(:membership, :tutor, user: tutor_user, organization: organization)
        section = build(:section, course: course, tutor: tutor_user)
        expect(section).to be_valid
      end

      it "is valid when tutor has admin role" do
        admin_user = create(:user)
        create(:membership, :admin, user: admin_user, organization: organization)
        section = build(:section, course: course, tutor: admin_user)
        expect(section).to be_valid
      end

      it "is invalid when tutor has tutorado role" do
        tutorado_user = create(:user)
        create(:membership, :tutorado, user: tutorado_user, organization: organization)
        section = build(:section, course: course, tutor: tutorado_user)
        expect(section).not_to be_valid
        expect(section.errors[:tutor]).to include("must have tutor or admin role")
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:tutor).class_name("User") }
  end

  describe "schedule JSONB" do
    let(:organization) { create(:organization) }
    let(:academic_period) { create(:academic_period, organization: organization) }
    let(:course) { create(:course, academic_period: academic_period) }
    let(:tutor_user) { create(:user) }

    before do
      create(:membership, :tutor, user: tutor_user, organization: organization)
    end

    it "defaults to empty hash" do
      section = create(:section, course: course, tutor: tutor_user)
      expect(section.schedule).to eq({})
    end

    it "stores JSONB schedule data" do
      schedule = {"monday" => {"start" => "09:00", "end" => "10:30"}}
      section = create(:section, course: course, tutor: tutor_user, schedule: schedule)
      section.reload
      expect(section.schedule["monday"]["start"]).to eq("09:00")
    end
  end
end
