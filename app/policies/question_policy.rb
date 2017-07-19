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

  def create?
    assert_publish_type
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    rule is_member?, is_manager?, super
  end

  def update?
    rule (is_member? && is_creator?), is_manager?, super
  end
end
