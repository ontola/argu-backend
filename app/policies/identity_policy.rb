# frozen_string_literal: true
class IdentityPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attributes
    super
  end

  def destroy?
    record.user_id == user.id
  end
end
