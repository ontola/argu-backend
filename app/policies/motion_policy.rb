class MotionPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

  end

  def index?
    user && user.profile.memberships.where(forum: record).present? || super
  end
end
