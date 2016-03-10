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
      if context.forum.present?
        scope.where(forum_id: context.forum.id).published
      elsif user.present? && user.profile.memberships.present?
        scope.where(forum_id: user.profile.memberships.pluck(:forum_id)).published
      end
    end
  end

  def permitted_attributes
    attributes = super
    attributes << %i(title content votes tag_list cover_photo remove_cover_photo
                     cover_photo_attribution question_id) if create?
    attributes << [{question_answers_attributes: [:id, :question_id, :motion_id]}] if create?
    attributes << %i(id) if record.is_a?(Motion) && edit?
    attributes << %i(invert_arguments tag_id forum_id f_convert) if staff?
    attributes
  end

  def convert
    rule move?
  end

  def convert?
    rule move?
  end

  def create?
    rule is_member?, is_manager?, is_owner?, super
  end

  def create_without_question?
    rule is_member?, is_manager?, is_owner?, staff?
  end

  def destroy?
    user && (record.creator_id == user.profile.id && record.arguments.length < 2 or 15.minutes.ago < record.created_at) || is_manager? || is_owner? || super
  end

  def edit?
    rule update?
  end

  def index?
    rule is_member?, super
  end

  def new?
    rule is_open?, is_member?, is_manager?, staff?
  end

  def new_without_question?
    rule is_open?, is_member?, is_manager?, staff?
  end

  def show?
    rule is_open?, has_access_token?, is_member?, is_manager?, is_owner?, super
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
