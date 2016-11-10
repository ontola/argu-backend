# frozen_string_literal: true
class GroupMembershipPolicy < EdgeTreePolicy
  include JWTHelper, UriTemplateHelper
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      scope
        .joins(:group)
        .where('groups.visibility != ? OR group_memberships.group_id IN (?)',
               Group.visibilities[:hidden],
               @profile.group_ids)
    end
  end

  def permitted_attributes
    attributes = [:lock_version, :token]
    attributes.append(:shortname) if rule(is_manager?, is_super_admin?, staff?)
    attributes
  end

  def create?
    rule valid_token?, is_manager?, is_super_admin?, super
  end

  def destroy?
    if record.group.grants.member.present?
      actor && (record.member == actor || (page_policy.update? || staff?))
    else
      rule Pundit.policy(context, record.group).remove_member?(record), super
    end
  end

  private

  def granted_resource
    record.parent_model.grants.member.first.edge.owner
  end

  def page_policy
    Pundit.policy(context, persisted_edge.get_parent(:page).owner)
  end

  def token
    2
  end

  def valid_token?
    return unless record.token.present?
    response = HTTParty.get(
      expand_uri_template(:verify_token, jwt: sign_payload(secret: record.token, group_id: record.group_id))
    )
    token if response.code == 200
  end
end
