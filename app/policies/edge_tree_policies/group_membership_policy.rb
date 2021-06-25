# frozen_string_literal: true

class GroupMembershipPolicy < EdgeTreePolicy
  include UriTemplateHelper

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
    %i[token]
  end

  def show?
    record.member == profile || edgeable_policy.update?
  end

  def create?
    valid_token?
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

    Argu::API.service_api.verify_token(record.token, record.group_id)
  end
end
