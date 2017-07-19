# frozen_string_literal: true
class MotionPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

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
    return create_without_question? unless record.parent_model.is_a?(Question)
    super
  end

  def create_without_question?
    create_asserts
    rule is_member?, is_manager?, is_super_admin?, staff?
  end

  def statistics?
    rule is_manager?, is_super_admin?, super
  end

  private

  def create_asserts
    assert_publish_type
    super
  end

  alias create_roles default_create_roles
  alias destroy_roles default_destroy_roles
  alias trash_roles default_trash_roles
  alias untrash_roles default_untrash_roles
  alias update_roles default_update_roles
  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles
end
