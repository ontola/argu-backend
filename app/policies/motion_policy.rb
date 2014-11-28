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

  def show?
    is_member? || super
  end

  def vote?
    is_member? || super
  end

  private

  def is_member?
    user.profile.member_of? record.forum
  end
end
