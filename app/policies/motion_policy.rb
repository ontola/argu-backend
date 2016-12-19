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
    attributes
  end

  def convert?
    rule is_manager?, is_owner?, staff?
  end

  def create?
    return create_without_question? unless record.question.present?
    return nil if record.question.present? && record.question.expired?
    rule is_member?, is_manager?, is_owner?, super
  end

  def create_without_question?
    rule is_member?, is_manager?, is_owner?, staff?
  end

  def destroy?
    user && (is_creator? &&
             (record.arguments.length < 2 || 15.minutes.ago < record.created_at)) ||
      is_manager? ||
      is_owner? ||
      super
  end

  def new_without_question?
    create_without_question?
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule has_access_token?, is_member?, is_manager?, is_owner?, super
  end

  def trash?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def untrash?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def update?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def vote?
    rule is_member?, super
  end
end
