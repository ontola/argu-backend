class ActivityPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(['forum_id IN (%s)', user.profile.memberships.pluck(:forum_id).join(',')])
    end
  end

  def permitted_attributes
    attributes = super
    attributes
  end

end
