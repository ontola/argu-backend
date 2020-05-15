# frozen_string_literal: true

module ChildrenPlaceable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :children_placements_iri, predicate: NS::ARGU[:childrenPlacements]
    end
  end
end
