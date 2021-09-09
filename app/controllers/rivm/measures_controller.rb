# frozen_string_literal: true

class MeasuresController < EdgeableController
  has_collection_create_action(
    favorite: true
  )
end
