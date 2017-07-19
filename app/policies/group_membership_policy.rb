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
    attributes.append(:shortname) if is_super_admin? || staff?
    attributes
  end

  def show?
    record.member == actor
  end

  private

  def create_roles
    [valid_token?, is_super_admin?, super]
  end

  def destroy_roles
    return [] if record.group.grants.super_admin.present? && record.group.group_memberships.count <= 1
    [is_creator?, is_super_admin?, super]
  end

  def is_creator?
    creator if record.member == user.profile
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
