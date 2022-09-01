# frozen_string_literal: true

class MotionPolicy < DiscussionPolicy
  permit_attributes %i[display_name description]
  permit_attributes %i[pinned options_vocab_id], grant_sets: %i[moderator administrator]

  def convert?
    staff?
  end
end
