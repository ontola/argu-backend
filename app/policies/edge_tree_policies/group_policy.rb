# frozen_string_literal: true

class GroupPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[name display_name name_singular require_2fa]
  permit_nested_attributes %i[grants]

  def is_member?
    user&.profile&.is_group_member?(record.id)
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[members invite edit grants advanced] if edgeable_policy.update?
    tabs.concat %i[email_invite bearer_invite delete] if edgeable_policy.update?
    tabs
  end

  def show?
    true
  end

  def create?
    return false unless edgeable_policy.update?
    return forbid_wrong_tier unless feature_enabled?(:groups)

    true
  end

  def update?
    return false unless edgeable_policy.update?
    return forbid_wrong_tier unless record.deletable || feature_enabled?(:groups)

    true
  end

  def destroy?
    return forbid_with_message(I18n.t('groups.delete.not_allowed')) unless record.deletable
    return false unless edgeable_policy.update?
    return forbid_wrong_tier unless feature_enabled?(:groups)

    true
  end

  def default_tab
    'members'
  end
end
