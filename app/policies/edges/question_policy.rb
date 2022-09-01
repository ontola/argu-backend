# frozen_string_literal: true

class QuestionPolicy < DiscussionPolicy
  permit_attributes %i[display_name description]
  permit_attributes %i[pinned require_location default_options_vocab_id map_question default_motion_sorting
                       default_motion_display],
                    grant_sets: %i[moderator administrator]

  def convert?
    staff?
  end
end
