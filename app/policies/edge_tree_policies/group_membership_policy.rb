# frozen_string_literal: true

class GroupMembershipPolicy < EdgeTreePolicy
  include UriTemplateHelper
  include ServiceHelper
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

  def permitted_attribute_names
    attributes = %i[token]
    attributes.append(:shortname) if edgeable_policy.update?
    attributes
  end

  def show?
    record.member == actor || edgeable_policy.update?
  end

  def create?
    valid_token? || !vnext? && edgeable_policy.update?
  end

  def destroy?
    return false if record.group.grants.administrator.present? && record.group.group_memberships.count <= 1
    group_member? || edgeable_policy.update?
  end

  private

  def group_member?
    record.member == user.profile
  end

  def valid_token?
    return if record.token.blank?
    response =
      HTTParty
        .get(
          expand_service_url(
            :token,
            expand_uri_template(:verify_token),
            jwt: sign_payload(secret: record.token, group_id: record.group_id)
          )
        )
    response.code == 200
  end
end
