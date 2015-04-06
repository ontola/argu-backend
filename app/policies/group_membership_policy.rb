class GroupMembershipPolicy < RestrictivePolicy
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
    attributes
  end

  def destroy?
    Pundit.policy(context, record.group).remove_member?(record) || super
  end

private

  def is_manager?
    Pundit.policy(context, record.forum).is_manager?
  end

  def profile_in_group?
    actor && (record.forum.groups & actor.groups).present?
  end

end
