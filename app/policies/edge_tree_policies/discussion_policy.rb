# frozen_string_literal: true

class DiscussionPolicy < EdgeTreePolicy
  def show?
    edgeable_policy.list?
    edgeable_policy.show?
  end
  alias create? show?
end
