# frozen_string_literal: true

module ChildrenPlaceable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :children_placements, predicate: NS.argu[:childrenPlacements]
    end
  end
end
