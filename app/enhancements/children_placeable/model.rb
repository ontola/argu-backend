# frozen_string_literal: true

module ChildrenPlaceable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :children_placements,
                      association_class: Placement,
                      route_key: :placements
    end

    def children_placements
      @children_placements ||=
        Placement
          .joins('INNER JOIN edges ON placements.edge_id = edges.uuid')
          .where(edges: {parent_id: id})
    end

    def children_placements_iri
      collection_iri(:children_placements)
    end
  end
end
