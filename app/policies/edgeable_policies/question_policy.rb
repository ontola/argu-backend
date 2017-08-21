# frozen_string_literal: true

class QuestionPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end

  def permitted_attributes
    attributes = super
    if create?
      attributes.concat %i[id title content forum_id project_id cover_photo
                           remove_cover_photo cover_photo_attribution]
    end
    attributes.concat %i[include_motions f_convert] if staff?
    attributes.concat %i[pinned require_location default_sorting] if is_manager? || staff?
    append_default_photo_params(attributes)
    append_attachment_params(attributes)
    attributes
  end

  def convert?
    rule staff?
  end

  def move?
    staff?
  end

  def invite?
    parent_policy(:page).update?
  end

  def update?
    rule (is_member? && is_creator?), is_manager?, super
  end
end
