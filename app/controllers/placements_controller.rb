# frozen_string_literal: true

class PlacementsController < ParentableController
  skip_before_action :check_if_registered, only: %i[index show]

  private

  def collection_from_parent_name
    :children_placement_collection
  end
end
