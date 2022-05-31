# frozen_string_literal: true

class FollowPolicy < RestrictivePolicy
  permit_attributes %i[follow_type]

  def create?
    Pundit.policy(context, record.followable).follow?
  end

  def destroy?
    !record.never?
  end

  def show?
    true
  end
end
