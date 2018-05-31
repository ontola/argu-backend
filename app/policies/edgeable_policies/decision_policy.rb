# frozen_string_literal: true

class DecisionPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[description]
    attributes.concat %i[state forwarded_user_id forwarded_group_id] if record.new_record?
    attributes.append(happening_attributes: %i[id happened_at])
    attributes
  end

  # @return [Boolean] Returns true if the Decision is assigned to the current_user or one of its groups
  def decision_is_assigned?
    record.parent.assigned_to_user?(user)
  end

  # Creating a Decision when a draft is present is not allowed
  # Managers and the Owner are allowed to forward a Decision when not assigned to him
  def create?
    return nil if record.parent.decisions.unpublished.present?
    if record.forwarded?
      decision_is_assigned? || has_grant?(:create)
    else
      decision_is_assigned?
    end
  end

  def destroy?
    false
  end

  def feed?
    false
  end

  def update?
    decision_is_assigned? || is_creator? || has_grant?(:update)
  end
end
