# frozen_string_literal: true

class QuestionPolicy < DiscussionPolicy
  permit_attributes %i[display_name description]
  permit_attributes %i[pinned require_location upvote_only map_question default_motion_sorting],
                    grant_sets: %i[moderator administrator staff]

  def convert?
    staff?
  end
end
