# frozen_string_literal: true

class MotionPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end

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

  def convert?
    rule is_manager?, is_super_admin?, staff?
  end

  def create?
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    return create_without_question? unless record.parent_model.is_a?(Question)
    rule is_member?, is_manager?, is_super_admin?, super
  end

  def create_without_question?
    rule is_member?, is_manager?, is_super_admin?, staff?
  end

  def invite?
    parent_policy(:page).update?
  end

  def update?
    rule is_creator?, is_manager?, is_super_admin?, super
  end

  def statistics?
    rule is_manager?, is_super_admin?, staff?
  end
end
