# frozen_string_literal: true
class QuestionPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
  end

  def children_classes
    super.append(:question_answers)
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(id title content tag_list forum_id project_id cover_photo
                         remove_cover_photo cover_photo_attribution expires_at) if create?
    attributes.concat %i(include_motions f_convert) if staff?
    attributes.concat %i(pinned) if is_manager? || staff?
    append_default_photo_params(attributes)
    attributes
  end

  def convert
    rule move?
  end

  def convert?
    rule move?
  end

  def create?
    rule is_member?, is_manager?, super
  end

  def destroy?
    user &&
      (record.creator_id == user.profile.id &&
        15.minutes.ago < record.created_at ||
        record.motions.count.zero?) ||
      is_manager? ||
      is_owner? ||
      super
  end

  def set_expire_as?
    rule staff?
  end

  def show?
    rule has_access_token?, is_member?, is_manager?, is_owner?, super
  end

  def trash?
    user && record.creator_id == user.profile.id || is_manager? || super
  end

  def untrash?
    user && record.creator_id == user.profile.id || is_manager? || super
  end

  def update?
    rule (is_member? && is_creator?), is_manager?, super
  end
end
