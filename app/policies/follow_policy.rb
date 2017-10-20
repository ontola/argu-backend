# frozen_string_literal: true

class FollowPolicy < RestrictivePolicy
  def show?
    true
  end
end
