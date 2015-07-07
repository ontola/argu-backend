class QuestionPolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

  class Scope < RestrictivePolicy::Scope
    attr_reader :context, :scope

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
    rule is_member?, is_manager?, super
  end

  def edit?
     rule update?
  end

  def destroy?
    user && (record.creator_id == user.profile.id && 15.minutes.ago < record.created_at or record.motions.count == 0) || is_owner? || super
  end

  def index?
    rule is_member?, super
  end

  def new?
    rule is_open?, is_member?, create?
  end

  def set_expire_as?
    rule staff?
  end

  def show?
    rule forum_policy.show?, super
  end

  def trash?
    user && record.creator_id == user.profile.id || is_manager? || super
  end

  def update?
    rule (is_member? && is_creator?), is_manager?, super
  end

end
