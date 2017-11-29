# frozen_string_literal: true

class GrantSetPolicy < RestrictivePolicy
  def show?
    staff?
  end
end
