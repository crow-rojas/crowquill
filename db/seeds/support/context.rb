# frozen_string_literal: true

module CrowquillSeeds
  DEFAULT_PASSWORD = "Password123456"

  class << self
    def base_state
      {
        random: Random.new(20_260_402),
        organizations: {},
        users: {},
        tutors: [],
        students: [],
        org_admins: {},
        org_tutors: {},
        org_students: {},
        periods_by_org: {},
        courses_by_org: Hash.new do |hash, key|
          hash[key] = {archived: [], active: [], draft: []}
        end,
        sections_by_org: Hash.new do |hash, key|
          hash[key] = {archived: [], active: [], draft: []}
        end
      }
    end

    def state
      @state ||= base_state
    end

    def reset_state!
      @state = base_state
    end

    def random
      state.fetch(:random)
    end
  end
end
