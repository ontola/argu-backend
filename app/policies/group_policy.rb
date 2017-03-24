# frozen_string_literal: true
class GroupPolicy < EdgeTreePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      # Don't show closed, unless the user has a membership
      scope.where('visibility IN (?) OR groups.id IN (?)',
                  [Group.visibilities[:open], Group.visibilities[:discussion]],
                  user.profile.group_memberships.pluck(:group_id))
    end
  end

  def is_member?
    member if user&.profile&.group_memberships&.pluck(:group_id)&.include? record.id
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(name name_singular icon visibility) if create?
    attributes.append :id if staff?
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(members invite general) if is_manager? || staff?
    tabs.concat %i(grants advanced) if is_super_admin? || staff?
    tabs
  end

  def show?
    rule is_member?, is_manager?, is_super_admin?, service?, super
  end

  def create?
    rule is_manager?, super()
  end

  def delete?
    destroy?
  end

  def destroy?
    return false unless record.deletable
    rule is_super_admin?, super
  end

  def settings?
    update?
  end

  def update?
    rule is_manager?, super
  end

  def remove_member?(_member)
    rule is_manager?
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'members'
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end
end
