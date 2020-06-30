# frozen_string_literal: true

class GroupPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[name display_name name_singular]
  permit_nested_attributes %i[grants]

  def is_member?
    user&.profile&.is_group_member?(record.id)
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[members invite general grants advanced] if edgeable_policy.update?
    tabs.concat %i[email_invite bearer_invite delete] if edgeable_policy.update?
    tabs
  end
  delegate :update?, to: :edgeable_policy

  def show?
    [Group::PUBLIC_ID, Group::STAFF_ID].include?(record.id) || is_member? || service? || edgeable_policy.update?
  end

  def create?
    edgeable_policy.update?
  end

  def destroy?
    if !record.deletable || record.default_decision_forums.any?
      return forbid_with_message(I18n.t('groups.delete.not_allowed'))
    end

    edgeable_policy.update?
  end

  def default_tab
    'members'
  end

  def valid_child?(klass)
    return true if klass == Grant

    super
  end
end
