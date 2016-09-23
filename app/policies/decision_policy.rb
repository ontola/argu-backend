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
    attributes.concat %i(content)
    attributes.concat %i(state forwarded_user_id forwarded_group_id) if record.new_record?
    attributes.append(happening_attributes: %i(id happened_at))
    attributes.append(argu_publication_attributes: %i(id publish_type))
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

  # Creating a Decision when a draft is present is not allowed
  # Managers and the Owner are allowed to forward a Decision when not assigned to him
  def create?
    return nil if record.decisionable.decisions.unpublished.present?
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
