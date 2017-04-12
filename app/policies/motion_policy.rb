# frozen_string_literal: true
class MotionPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(title content votes tag_list question_id) if create?
    attributes.concat %i(invert_arguments tag_id forum_id f_convert) if staff?
    attributes.concat %i(pinned) if is_manager? || staff?
    attributes.append :id if record.is_a?(Motion) && edit?
    attributes.append(question_answers_attributes: %i(id question_id motion_id)) if create?
    append_default_photo_params(attributes)
    append_attachment_params(attributes)
    attributes
  end

  def permitted_publish_types
    publish_types = Publication.publish_types
    is_manager? || is_super_admin? || staff? ? publish_types : publish_types.except('schedule')
  end

  def convert?
    rule is_manager?, is_super_admin?, staff?
  end

  def create?
    assert_publish_type
    return create_without_question? unless record.parent_model.is_a?(Question)
    return create_expired? if has_expired_ancestors?
    rule is_member?, is_manager?, is_super_admin?, super
  end

  def create_without_question?
    rule is_member?, is_manager?, is_super_admin?, staff?
  end

  def destroy?
    (is_creator? && (record.arguments.length < 2 || 15.minutes.ago < record.created_at)) ||
      is_manager? ||
      is_super_admin? ||
      super
  end

  def new_without_question?
    create_without_question?
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule is_member?, is_manager?, is_super_admin?, super
  end

  def trash?
    rule is_creator?, is_manager?, is_super_admin?, super
  end

  def untrash?
    rule is_creator?, is_manager?, is_super_admin?, super
  end

  def update?
    rule is_creator?, is_manager?, is_super_admin?, super
  end

  def vote?
    rule is_member?, super
  end

  def statistics?
    rule is_manager?, is_super_admin?, super
  end
end
