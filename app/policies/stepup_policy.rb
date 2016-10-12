# frozen_string_literal: true
class StepupPolicy < EdgeTreePolicy
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
    attributes.concat %i(id group user moderator title description _destroy) if force || create?
    attributes
  end

  def create?
    rule is_manager?, is_owner?, super
  end

  def destroy?
    user && (record.creator_id == user.profile.id && 15.minutes.ago < record.created_at) ||
      is_manager? ||
      is_owner? ||
      super
  end

  def update?
    rule is_manager?, is_owner?, super
  end

  private

  def forum_policy
    Pundit.policy(context, context.forum)
  end
end
