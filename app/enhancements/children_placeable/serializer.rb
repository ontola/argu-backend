# frozen_string_literal: true

module ChildrenPlaceable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :children_placements, predicate: NS::ARGU[:childrenPlacements]
    end

    def children_placements
      object.children_placements_iri
    end
  end
end
