class ActorPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

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
    owner = record.profileable
    if owner.class == User
      owner == user
    else
      owner.owner == user.profile || owner.managerships.where(profile: user.profile).present?
    end
  end

end
