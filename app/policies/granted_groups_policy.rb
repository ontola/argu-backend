# frozen_string_literal: true

class GrantedGroupsPolicy < RestrictivePolicy
  def show?
    Pundit.policy(user_context, record.parent).show?
  end
end
