# frozen_string_literal: true

module Actions
  class EdgeableCollectionActions < CollectionActions
    include VotesHelper

    private

    def image
      return 'fa-plus' unless filtered_resource? && resource.filter['option'].present?
      "fa-#{icon_for_side(resource.filter['option'])}"
    end
  end
end
