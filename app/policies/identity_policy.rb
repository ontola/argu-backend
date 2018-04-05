# frozen_string_literal: true

class IdentityPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attribute_names
    super
  end

  def destroy?
    record.user_id == user.id
  end

  def connect?
    true
  end
end
