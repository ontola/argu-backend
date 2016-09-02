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
    group_grant if record.decisionable.owner.assigned_to_user?(user)
  end

  def permitted_attributes
    attributes = super
    attributes << %i(content)
    attributes << [happening_attributes: [:id, :happened_at]]
    attributes << [:state, :forwarded_user_id, :forwarded_group_id] if record.new_record?
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

  def new?
    create?
  end

  def create?
    if record.forwarded?
      rule decision_is_assigned?, is_manager?, is_owner?, super
    else
      rule decision_is_assigned?
    end
  end

  def update?
    rule decision_is_assigned?, is_creator?, is_manager?, is_owner?, super
  end

  private

  def parent_policy
    Pundit.policy(context, record.decisionable.owner)
  end
end
