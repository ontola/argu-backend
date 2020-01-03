# frozen_string_literal: true

module ChildrenPlaceable
  module Model
    def children_placements_iri
      collection_iri(self, :placements)
    end
  end
end
