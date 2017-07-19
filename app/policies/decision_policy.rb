# frozen_string_literal: true
class DecisionPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i(content)
    attributes.concat %i(state forwarded_user_id forwarded_group_id) if record.new_record?
    attributes.append(happening_attributes: %i(id happened_at))
    attributes
  end

  def destroy?
    false
  end

  def feed?
    false
  end

  private

  def create_asserts
    assert_publish_type
    super
  end

  # Creating a Decision when a draft is present is not allowed
  # Managers and the Owner are allowed to forward a Decision when not assigned to him
  def create_roles
    return [] if record.edge.parent.decisions.unpublished.present?
    if record.forwarded?
      [decision_is_assigned?, is_manager?, is_super_admin?, super]
    else
      [decision_is_assigned?]
    end
  end

  # @return [Boolean] Returns true if the Decision is assigned to the current_user or one of its groups
  def decision_is_assigned?
    group_grant if record.parent_model.assigned_to_user?(user)
  end

  def update_roles
    [decision_is_assigned?, is_creator?, is_manager?, is_super_admin?, super]
  end

  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles
end
