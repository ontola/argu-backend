class ActorPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    is_manager?
  end

  def update?
    is_manager?
  end

  private
  def is_manager?
    owner = record.owner
    if owner.class == User
      owner == user
    else
      owner.owner == user.profile || owner.managers.where(profile: user.profile).present?
    end
  end

end
