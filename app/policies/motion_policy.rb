class MotionPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes << [:title, :content, :arguments, :tag_list] if create?
    attributes << [:id] if edit?
    attributes << [:invert_arguments, :tag_id] if staff?
  end

  def new?
    create?
  end

  def create?
    is_member? || super
  end

  def edit?
    is_member? && is_creator? || super
  end

  def index?
    is_member? || super
  end

  def show?
    is_member? || super
  end

  def vote?
    is_member? || super
  end

  private

  def is_member?
    user.profile.member_of? (record.forum || record.forum_id)
  end
end
