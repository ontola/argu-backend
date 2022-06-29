# frozen_string_literal: true

module ChildrenPlaceable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :children_placements,
                      association_class: Placement
    end

    def children_placements
      @children_placements ||=
        Placement
          .custom
          .joins('INNER JOIN edges ON placements.placeable_type = \'Edge\' AND placements.placeable_id = edges.uuid')
          .where(edges: {parent_id: id})
          .includes(:place)
    end

    def children_placements_iri
      collection_iri(:children_placements)
    end
  end
end
