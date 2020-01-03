# frozen_string_literal: true

module ChildrenPlaceable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :children_placeable do
        resources :placements, only: %i[index]
      end
    end
  end
end
