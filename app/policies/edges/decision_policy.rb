# frozen_string_literal: true

class DecisionPolicy < EdgePolicy
  permit_attributes %i[description]
  permit_attributes %i[state forwarded_user_id forwarded_group_id], new_record: true

  # Creating a Decision when a draft is present is not allowed
  # Managers and the Owner are allowed to forward a Decision when not assigned to him
  def create?
    false
  end

  def destroy?
    false
  end

  def update?
    is_creator? || has_grant?(:update)
  end

  class << self
    def valid_state_options
      %w[approved rejected]
    end
  end
end
