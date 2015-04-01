class QuestionPolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
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

    def is_member?
      user.profile.member_of? record.forum
    end

  end

  def permitted_attributes
    attributes = super
    attributes << [:id, :title, :content, :tag_list, :forum_id, :cover_photo, :remove_cover_photo, :cover_photo_attribution, :expires_at] if create?
    attributes << [:include_motions, :f_convert] if staff?
    attributes
  end

  def create?
    is_member? || super
  end

  def edit?
     update?
  end

  def destroy?
    user && (record.creator_id == user.profile.id && 15.minutes.ago < record.created_at or record.motions.count == 0) || is_owner? || super
  end

  def index?
    is_member? || super
  end

  def new?
    record.forum.open? || create?
  end

  def set_expire_as?
    staff?
  end

  def show?
    Pundit.policy(context, record.forum).show? || super
  end

  def trash?
    user && record.creator_id == user.profile.id || is_manager? || super
  end

  def update?
    is_member? && is_creator? || super
  end

  private

  def is_manager?
    Pundit.policy(context, record.forum).is_manager?
  end

  def is_member?
    user && user.profile.member_of?(record.forum || record.forum_id)
  end

  def is_owner?
    Pundit.policy(context, record.forum).is_owner?
  end
end
