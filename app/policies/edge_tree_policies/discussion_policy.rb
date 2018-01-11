# frozen_string_literal: true

class DiscussionPolicy < EdgeTreePolicy
  def show?
    edgeable_policy.list?
    edgeable_policy.show?
  end
  alias create? show?

  private

  def edgeable_record
    @edgeable_record ||= record.parent_model
  end
end
