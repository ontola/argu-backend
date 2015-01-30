class VotePolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :user, :scope, :session

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @memberships = @profile.memberships if @profile
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      if staff?
        scope
      else
        scope
      end
    end

  end

end
