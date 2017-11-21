# frozen_string_literal: true

class QuestionPolicy < EdgeablePolicy
  def permitted_attributes
    attributes = super
    if create?
      attributes.concat %i[id title content forum_id cover_photo
                           remove_cover_photo cover_photo_attribution]
    end
    attributes.concat %i[include_motions f_convert] if staff?
    if moderator? || administrator? || staff?
      attributes.concat %i[pinned require_location default_sorting reset_create_motion]
      attributes.concat [create_motion_group_ids: []]
    end
    append_default_photo_params(attributes)
    append_attachment_params(attributes)
    attributes
  end

  def convert?
    staff?
  end

  def move?
    staff?
  end

  def invite?
    parent_policy(:page).update?
  end
end
