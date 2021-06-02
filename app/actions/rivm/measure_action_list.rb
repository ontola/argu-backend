# frozen_string_literal: true

class MeasureActionList < EdgeActionList
  has_collection_create_action(
    favorite: true
  )
end
