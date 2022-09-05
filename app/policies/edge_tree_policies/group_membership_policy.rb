# frozen_string_literal: true

class GroupMembershipPolicy < EdgeTreePolicy
  include URITemplateHelper

  class Scope < Scope
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
    return forbid_with_message(I18n.t('actions.group_memberships.destroy.errors.last_admin')) if last_admin?
    return false if record.group.users?

    group_member? || edgeable_policy.update?
  end

  private

  def group_member?
    record.member == user.profile
  end

  def last_admin?
    record.group.admin? && record.group.group_memberships.count <= 1
  end

  def valid_token?
    return if record.token.blank?

    return true if Argu::API.new.verify_token(record.token, record.group_id)

    forbid_with_message(I18n.t('actions.group_memberships.create.errors.invalid_token'))
  end
end
