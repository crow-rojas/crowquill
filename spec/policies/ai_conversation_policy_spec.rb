# frozen_string_literal: true

require "rails_helper"

RSpec.describe AiConversationPolicy do
  let(:organization) { create(:organization) }
  let(:admin_membership) { create(:membership, :admin, organization: organization) }
  let(:tutor_membership) { create(:membership, :tutor, organization: organization) }
  let(:tutorado_membership) { create(:membership, :tutorado, organization: organization) }

  describe "#index?" do
    it "allows any member" do
      [admin_membership, tutor_membership, tutorado_membership].each do |membership|
        expect(described_class.new(membership).index?).to be true
      end
    end

    it "denies nil membership" do
      expect(described_class.new(nil).index?).to be false
    end
  end

  describe "#show?" do
    it "allows any member" do
      [admin_membership, tutor_membership, tutorado_membership].each do |membership|
        expect(described_class.new(membership).show?).to be true
      end
    end
  end

  describe "#create?" do
    it "allows any member" do
      [admin_membership, tutor_membership, tutorado_membership].each do |membership|
        expect(described_class.new(membership).create?).to be true
      end
    end

    it "denies nil membership" do
      expect(described_class.new(nil).create?).to be false
    end
  end
end
