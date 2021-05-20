# frozen_string_literal: true

class PlacementsController < ParentableController
  private

  def collection_from_parent_name
    :children_placement_collection
  end
end
