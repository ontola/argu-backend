# frozen_string_literal: true

class OntologyPolicy < RestrictivePolicy
  def show?
    true
  end

  def public_resource?
    true
  end
end
