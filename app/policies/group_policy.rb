# frozen_string_literal: true
class GroupPolicy < EdgeTreePolicy
  include PagePolicy::PageRoles

  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      # Don't show closed, unless the user has a membership
      scope.where('visibility IN (?) OR groups.id IN (?)',
                  [Group.visibilities[:open], Group.visibilities[:discussion]],
                  user && user.profile.group_memberships.pluck(:group_id))
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(name name_singular icon visibility) if create?
    attributes.append :id if staff?
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(general members invite) if is_manager? || staff?
    tabs.concat %i(grants) if is_owner? || staff?
    tabs
  end

  def create?
    rule is_manager?, super()
  end

  def delete?
    destroy?
  end

  def destroy?
    return false unless record.deletable
    rule is_owner?, super
  end

  def settings?
    update?
  end

  def new?
    create?
  end

  def update?
    rule is_manager?, super
  end

  def remove_member?(_member)
    rule is_manager?
  end

  def page_policy
    Pundit.policy(context, record.edge.parent.owner)
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= 'general'
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end
end
