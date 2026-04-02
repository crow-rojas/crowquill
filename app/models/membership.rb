# frozen_string_literal: true

class Membership < ApplicationRecord
  ROLES = %w[admin tutor tutorado].freeze

  belongs_to :user
  belongs_to :organization

  validates :role, presence: true, inclusion: {in: ROLES}
  validates :user_id, uniqueness: {scope: :organization_id}

  enum :role, ROLES.index_by(&:itself), validate: true

  def admin_or_above?
    admin?
  end

  def tutor_or_above?
    admin? || tutor?
  end
end
