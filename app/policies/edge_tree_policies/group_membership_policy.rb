# frozen_string_literal: true

class GroupMembershipPolicy < EdgeTreePolicy
  include UriTemplateHelper
  include JWTHelper
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

  def permitted_attributes
    attributes = %i[lock_version token]
    attributes.append(:shortname) if edgeable_policy.update?
    attributes
  end

  def show?
    record.member == actor
  end

  def create?
    valid_token? || edgeable_policy.update?
  end

  def destroy?
    return false if record.group.grants.super_admin.present? && record.group.group_memberships.count <= 1
    is_group_member? || edgeable_policy.update?
  end

  private

  def edgeable_record
    @edgeable_record ||= record.page
  end

  def is_group_member?
    creator if record.member == user.profile
  end

  def token
    2
  end

  def valid_token?
    return if record.token.blank?
    response = HTTParty.get(
      expand_uri_template(:verify_token, jwt: sign_payload(secret: record.token, group_id: record.group_id))
    )
    token if response.code == 200
  end
end
