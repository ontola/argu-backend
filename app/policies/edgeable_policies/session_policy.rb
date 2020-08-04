# frozen_string_literal: true

class SessionPolicy < RestrictivePolicy
  permit_attributes %i[email r]

  def create?
    true
  end
end
