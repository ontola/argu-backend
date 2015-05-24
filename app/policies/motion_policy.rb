class MotionPolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

  class Scope < Scope
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
  end

  def permitted_attributes
    attributes = super
    attributes << [:title, :content, :votes, :tag_list, :cover_photo, :remove_cover_photo, :cover_photo_attribution] if create?
    attributes << [:id] if edit?
    attributes << [:invert_arguments, :tag_id, :forum_id, :f_convert] if staff?
    attributes
  end

  def create?
    rule is_member?, is_manager?, is_owner?, super
  end

  def create_without_question?
    rule is_member?, is_manager?, is_owner?, staff?
  end

  def destroy?
    user && (record.creator_id == user.profile.id && record.arguments.length < 2 or 15.minutes.ago < record.created_at) || forum_policy.is_owner? || super
  end

  def edit?
    rule update?
  end

  def index?
    rule is_member?, super
  end

  def new?
    rule is_open?, is_member?, staff?
  end

  def show?
    rule forum_policy.show?, super
  end

  def trash?
    user && record.creator_id == user.profile.id || is_manager? || is_owner? || super
  end

  def update?
    rule (is_member? && is_creator?), is_manager?, is_owner?, super
  end

  def vote?
    rule is_member?, super
  end

end
