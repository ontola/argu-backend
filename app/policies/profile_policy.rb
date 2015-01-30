class ProfilePolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :user, :scope, :session

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
    record.owner.finished_intro? || super
  end

  def update?
    record.owner == user || super
  end

  def edit?
    update?
  end
end
