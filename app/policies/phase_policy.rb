class PhasePolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

  class Scope < RestrictivePolicy::Scope
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

  def permitted_attributes(force = false)
    attributes = super()
    attributes << %i(id name description integer end_date finish_phase _destroy) if force || create?
    attributes
  end

  def create?
    rule is_moderator?, is_manager?, is_owner?, super
  end

  private

  def forum_policy
    Pundit.policy(context, context.forum)
  end
end
