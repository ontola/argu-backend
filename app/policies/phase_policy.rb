# frozen_string_literal: true
class PhasePolicy < EdgeTreePolicy
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
    attributes.concat %i(id name description integer end_date end_time finish_phase _destroy) if force || create?
    attributes.concat %i(name description end_date finish_phase) if update?
    attributes
  end

  def create?
    rule is_moderator?, is_manager?, is_owner?, super
  end

  def edit?
    rule update?
  end

  def show?
    if record.project.is_published? && !record.project.is_trashed?
      rule is_open?, has_access_token?, is_member?, is_moderator?, is_manager?, is_owner?, super
    else
      rule is_moderator?, is_manager?, is_owner?, super
    end
  end

  def update?
    rule is_moderator?, is_manager?, is_owner?, super
  end

  private

  def forum_policy
    Pundit.policy(context, context.forum)
  end
end
