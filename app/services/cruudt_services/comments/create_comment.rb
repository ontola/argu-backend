# frozen_string_literal: true

class CreateComment < CreateEdge
  private

  def current_vote(user, parent)
    user
      .profile
      .vote_cache
      .by_parent(parent.default_vote_event)
  end
end
