# frozen_string_literal: true

class AccessTokenPolicy < RestrictivePolicy
  permit_attributes %i[email password r]

  def create?
    true
  end
end
