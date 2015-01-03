class VotePolicy < RestrictivePolicy
  class Scope < Scope
    def initialize(user, scope)
      @profile = user.profile
      @memberships = @profile.memberships
      @scope = scope
    end

    def resolve
      if staff?
        scope
      else
        scope
      end
    end

  end

end
