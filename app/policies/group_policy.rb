class GroupPolicy < RestrictivePolicy
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

  def permitted_attributes
    attributes = super
    attributes << [:name, :name_singular, :icon, :max_responses_per_member] if create?
    attributes << [:id] if staff?
    attributes
  end

  def new?
    create?
  end

  def create?
    is_manager? || super
  end

  def update?
    is_manager? || super
  end

  def edit?
    update?
  end

  def remove_member?(member)
    is_manager? || super
  end

private

  def is_manager?
    Pundit.policy(context, record.forum).is_manager?
  end

end
