# frozen_string_literal: true

class QuestionPolicy < EdgeablePolicy
  def permitted_attribute_names
    attributes = super
    if create?
      attributes.concat %i[id title content forum_id cover_photo
                           remove_cover_photo cover_photo_attribution]
    end
    attributes.concat %i[f_convert] if staff?
    if moderator? || administrator? || staff?
      attributes.concat %i[pinned require_location default_sorting reset_create_motion]
      attributes.concat [create_motion_group_ids: []]
    end
    attributes
  end

  def convert?
    staff?
  end

  def move?
    staff? || administrator? || moderator?
  end

  def invite?
    parent_policy(:page).update?
  end
end
