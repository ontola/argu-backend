# frozen_string_literal: true
class CurrentActorPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    current_user && is_manager?
  end

  def update?
    current_user && is_manager?
  end

  private

  def current_user
    record.user == user
  end

  def is_manager?
    owner = record.actor.profileable
    if owner.class == User
      owner == user
    else
      owner.owner == user.profile ||
        (user.profile.page_ids(:manager) + user.profile.page_ids(:super_admin))
          .include?(owner.id)
    end
  end
end
