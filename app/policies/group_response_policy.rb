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
    page_in_group? && creator? || super
  end

  def update?
    page_in_group? && creator? || super
  end

  def edit?
    update?
  end

  def destroy?
    page_in_group? && creator? || super
  end

private

  def is_manager?
    Pundit.policy(context, record.forum).is_manager?
  end

  def page_in_group?
    if actor.owner.try(:groups)
      (record.forum.groups & actor.owner.groups).present?
    end
  end

  def creator?
    record.creator == actor
  end

end
