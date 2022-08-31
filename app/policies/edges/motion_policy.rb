# frozen_string_literal: true

class MotionPolicy < DiscussionPolicy
  permit_attributes %i[display_name description]
  permit_attributes %i[forum_id f_convert], grant_sets: %i[staff]
  permit_attributes %i[pinned options_vocab_id], grant_sets: %i[moderator administrator staff]

  def convert?
    staff?
  end
end
