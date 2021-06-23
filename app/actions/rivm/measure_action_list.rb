# frozen_string_literal: true

class MeasureActionList < EdgeActionList
  has_action(
    :create,
    create_options.merge(
      favorite: true
    )
  )
end
