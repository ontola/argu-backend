# frozen_string_literal: true
class QuestionPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i(id title content tag_list forum_id project_id cover_photo
                         remove_cover_photo cover_photo_attribution) if create?
    attributes.concat %i(include_motions f_convert) if staff?
    attributes.concat %i(pinned) if is_manager? || staff?
    append_default_photo_params(attributes)
    append_attachment_params(attributes)
    attributes
  end

  def permitted_publish_types
    publish_types = Publication.publish_types
    is_manager? || is_super_admin? || staff? ? publish_types : publish_types.except('schedule')
  end

  def convert?
    rule move?
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
