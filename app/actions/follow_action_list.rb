# frozen_string_literal: true

class FollowActionList < EdgeActionList
  has_resource_destroy_action(
    favorite: true
  )
end
