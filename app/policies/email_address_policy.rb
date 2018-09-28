# frozen_string_literal: true

class EmailAddressPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end

  def show?
    record.user == user
  end
end
