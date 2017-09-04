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
    end
  end

  def edge
    record.group.parent_edge(:page)
  end

  def permitted_attributes
    attributes = %i[lock_version token]
    attributes.append(:shortname) if rule(is_super_admin?, staff?)
    attributes
  end

  def show?
    record.member == actor
  end

  def create?
    rule valid_token?, is_super_admin?, super
  end

  def destroy?
    return false if record.group.grants.super_admin.present? && record.group.group_memberships.count <= 1
    rule is_group_member?, is_super_admin?, staff?
  end

  private

  def is_group_member?
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
