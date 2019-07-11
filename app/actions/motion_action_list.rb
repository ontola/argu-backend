# frozen_string_literal: true

class MotionActionList < EdgeActionList
  has_action(
    :create,
    create_options.merge(
      favorite: -> { association.to_sym == :votes }
    )
  )
end
