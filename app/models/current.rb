# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user_agent, :ip_address
  attribute :membership

  delegate :user, to: :session, allow_nil: true
  delegate :organization, to: :membership, allow_nil: true
end
