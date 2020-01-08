# frozen_string_literal: true

class FollowActionList < EdgeActionList
  has_action(
    :destroy,
    destroy_options.merge(
      favorite: true
    )
  )
end
