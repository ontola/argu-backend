# frozen_string_literal: true

class DraftPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope.where(creator_id: user.managed_profile_ids)
    end
  end
end
