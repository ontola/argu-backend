# frozen_string_literal: true

class ApplicationFormPolicy < RestrictivePolicy
  def show?
    true
  end

  def public_resource?
    true
  end
end
