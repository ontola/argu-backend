# frozen_string_literal: true
class DecisionPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
  end

  # @return [Boolean] Returns true if the Decision is assigned to the current_user or one of its groups
  def decision_is_assigned?
    group_grant if record.parent_model.assigned_to_user?(user)
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(content)
    attributes.concat %i(state forwarded_user_id forwarded_group_id) if record.new_record?
    attributes.append(happening_attributes: %i(id happened_at))
    attributes
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule parent_policy.show?
  end

  # Creating a Decision when a draft is present is not allowed
  # Managers and the Owner are allowed to forward a Decision when not assigned to him
  def create?
    return nil if record.edge.parent.decisions.unpublished.present?
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
    Pundit.policy(context, record.edge.parent.owner)
  end
end
