# frozen_string_literal: true

class TokenPolicy < RestrictivePolicy
  permit_attributes %i[email password r]

  def create?
    true
  end
end
