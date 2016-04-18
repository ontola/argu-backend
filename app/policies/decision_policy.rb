# frozen_string_literal: true
class DecisionPolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

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
      scope
    end
  end

  # @return [Boolean] Returns true if the Decision is assigned to the current_user or one of its groups
  def decision_is_assigned?
    if user.present? && user.profile.groups.include?(record.group)
      group_grant if record.user.nil? || user == record.user
    end
  end

  def permitted_attributes
    attributes = super
    attributes << %i(content)
    attributes << [happening_attributes: [:id, :happened_at]]
    attributes << [:state, forwarded_to_attributes: [:user_id, :group_id]] if record.pending?
    attributes
  end

  def edit?
    update?
  end

  def index?
    show?
  end

  def show?
    rule parent_policy.show?
  end

  def update?
    if record.forwarded? || record.pending?
      rule decision_is_assigned?, is_moderator?, is_manager?, is_owner?, super
    else
      rule decision_is_assigned?
    end
  end

  private

  def parent_policy
    Pundit.policy(context, record.decisionable)
  end
end
