class ArgumentPolicy < RestrictivePolicy
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
    attributes << [:title, :content, :pro, :motion_id, :forum_id] if create?
    attributes
  end

  def new?
    record.forum.open? || create?
  end

  def create?
    is_member? || super
  end

  def update?
    is_member? && is_creator? || forum_policy.is_manager? || forum_policy.is_owner? || super
  end

  def edit?
    update?
  end

  def trash?
    forum_policy.is_manager? || forum_policy.is_owner? || super
  end

  def destroy?
    forum_policy.is_owner? || super
  end

  def show?
    Pundit.policy(context, record.forum).show? || super
  end

  private

  def forum_policy
    Pundit.policy(context, record.forum)
  end

  def is_member?
    user && user.profile.member_of?(record.motion.forum)
  end
end
