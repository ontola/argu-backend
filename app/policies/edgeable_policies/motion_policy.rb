# frozen_string_literal: true

class MotionPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description votes question_id]
    attributes.concat %i[forum_id f_convert] if staff?
    attributes.concat %i[pinned] if moderator? || administrator? || staff?
    attributes.concat %i[trash_activity untrash_activity]
    attributes
  end

  def convert?
    staff?
  end

  def move?
    staff? || administrator? || moderator?
  end

  def decide?
    record.state == 'pending' && Pundit.policy(context, record.last_or_new_decision(true)).update?
  end
end
