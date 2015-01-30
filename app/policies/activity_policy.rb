class ActivityPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :user, :scope, :session

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      scope.where(['forum_id IN (%s)', user.profile.memberships_ids])
    end
  end

  def permitted_attributes
    attributes = super
    attributes
  end

end
