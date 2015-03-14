class GroupResponsePolicy < RestrictivePolicy
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

  def permitted_attributes
    attributes = super
    attributes << [:text, :side] if create?
    attributes << [:id] if staff?
    attributes
  end

  def new?
    create?
  end

  def create?
    profile_in_group?
  end

  def update?
    profile_in_group?
  end

  def edit?
    update?
  end

  def destroy?
    profile_in_group? && creator? || super
  end

private

  def is_manager?
    Pundit.policy(context, record.forum).is_manager?
  end

  def profile_in_group?
    (record.forum.groups & actor.groups).present?
  end

  def creator?
    record.creator == actor
  end

end
