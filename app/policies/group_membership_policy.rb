class GroupMembershipPolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

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

    delegate :is_manager?, to: :forum_policy
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
    if record.group.shortname == 'members'
      rule is_open?, has_access_token?, is_member?, is_manager?, super
    else
      rule is_manager?, is_owner?, super
    end
  end

  def destroy?
    if record.group.shortname == 'members'
      actor &&
        (record.member == actor || (forum_policy.update? || staff?) &&
          record.forum.memberships.where(role: Membership.roles[:manager]).where.not(id: record.id).present?)
    else
      rule Pundit.policy(context, record.group).remove_member?(record), super
    end
  end

  private

  def forum_policy
    Pundit.policy(context, record.edge.try(:forum) || context.context_model)
  end
end
