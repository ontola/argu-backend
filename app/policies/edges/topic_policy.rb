# frozen_string_literal: true

class TopicPolicy < DiscussionPolicy
  permit_attributes %i[display_name description]
  permit_attributes %i[pinned], grant_sets: %i[moderator administrator staff]

  def convert?
    staff?
  end
end
