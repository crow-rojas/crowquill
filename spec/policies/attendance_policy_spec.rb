# frozen_string_literal: true

require "rails_helper"

RSpec.describe AttendancePolicy do
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, :admin, organization: organization) }
  let(:tutor_membership) { create(:membership, :tutor, organization: organization) }
  let(:tutorado_membership) { create(:membership, :tutorado, organization: organization) }

  describe "#index?" do
    it "allows admin to view attendance" do
      expect(described_class.new(admin_membership).index?).to be true
    end

    it "allows tutor to view attendance" do
      expect(described_class.new(tutor_membership).index?).to be true
    end

    it "denies tutorado from viewing attendance" do
      expect(described_class.new(tutorado_membership).index?).to be false
    end
  end

  describe "#create?" do
    it "allows tutor or above to create attendance" do
      expect(described_class.new(admin_membership).create?).to be true
      expect(described_class.new(tutor_membership).create?).to be true
    end

    it "denies tutorado from creating attendance" do
      expect(described_class.new(tutorado_membership).create?).to be false
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
