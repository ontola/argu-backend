class MotionPolicy < RestrictivePolicy
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

  def create?
    is_member? || super
  end

  def destroy?
    user && (record.creator_id == user.profile.id && record.arguments.length < 2 or 15.minutes.ago < record.created_at) || forum_policy.is_owner? || super
  end

  def edit?
    update?
  end

  def index?
    is_member? || super
  end

  def new?
    record.forum.open? || create?
  end

  def show?
    forum_policy.show? || super
  end

  def trash?
    user && record.creator_id == user.profile.id || forum_policy.is_manager? || forum_policy.is_owner? || super
  end

  def update?
    is_member? && is_creator? || forum_policy.is_manager? || forum_policy.is_owner? || super
  end

  def vote?
    is_member? || super
  end

  private

  def forum_policy
    Pundit.policy(context, record.forum)
  end

  def is_member?
    user && user.profile.member_of?(record.forum || record.forum_id)
  end
end
