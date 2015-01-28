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
    attributes << [:title, :content, :votes, :tag_list, :cover_photo, :remove_cover_photo, :cover_photo_attribution] if create?
    attributes << [:id] if edit?
    attributes << [:invert_arguments, :tag_id, :forum_id, :f_convert] if staff?
    attributes
  end

  def new?
    record.forum.open? || create?
  end

  def create?
    is_member? || super
  end

  def update?
    is_member? && is_creator? || super
  end

  def edit?
    update?
  end

  def index?
    is_member? || super
  end

  def show?
    Pundit.policy(context, record.forum).show? || super
  end

  def vote?
    is_member? || super
  end

  private

  def is_member?
    user && user.profile.member_of?(record.forum || record.forum_id)
  end
end
