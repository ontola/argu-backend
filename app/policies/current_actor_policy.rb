# frozen_string_literal: true

class CurrentActorPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    current_user && moderator?
  end

  def update?
    current_user && moderator?
  end

  private

  def current_user
    record.user == user
  end

  def moderator?
    owner = record.actor.profileable
    if owner.class == User || owner.class == GuestUser
      owner == user
    else
      return unless user.confirmed?
      owner.owner == user.profile || user.managed_profile_ids.include?(owner.profile.id)
    end
  end
end
