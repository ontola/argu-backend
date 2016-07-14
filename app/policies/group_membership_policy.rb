class GroupMembershipPolicy < RestrictivePolicy
  include PagePolicy::PageRoles

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

  module Roles
    def profile_in_group?
      actor && (record.forum.groups & actor.groups).present?
    end

    def is_open?
      open if record.group.grants.member.first.edge.owner.open?
    end

    delegate :is_manager?, to: :page_policy
  end
  include Roles

  def permitted_attributes
    attributes = [:lock_version]
    attributes.append(:shortname) if rule(is_manager?, is_owner?, staff?)
    attributes
  end

  def new?
    create?
  end

  def create?
    if record.group.grants.member.present?
      rule is_open?, is_member?, is_manager?, super
    else
      rule is_manager?, is_owner?, super
    end
  end

  def destroy?
    if record.group.grants.member.present?
      actor && (record.member == actor || (page_policy.update? || staff?))
    else
      rule Pundit.policy(context, record.group).remove_member?(record), super
    end
  end

  private

  def page_policy
    Pundit.policy(context, record&.group&.page || context.context_model)
  end
end
