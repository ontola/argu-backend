# frozen_string_literal: true
class VoteMatchPolicy < RestrictivePolicy
  def show?
    true
  end
end
