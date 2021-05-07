# frozen_string_literal: true

class DraftPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      return scope.none if user.nil?

      scope.where(creator_id: user.managed_profile_ids)
    end
  end
end
