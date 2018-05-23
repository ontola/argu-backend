# frozen_string_literal: true

class MotionPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[title content votes question_id]
    attributes.concat %i[invert_arguments forum_id f_convert] if staff?
    attributes.concat %i[pinned] if moderator? || administrator? || staff?
    attributes
  end

  def convert?
    staff?
  end

  def move?
    staff? || administrator? || moderator?
  end

  def decide?
    Pundit.policy(context, record.last_or_new_decision(true)).update?
  end

  def invite?
    parent_policy(:page).update?
  end
end
