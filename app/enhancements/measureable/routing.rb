# frozen_string_literal: true

module Measureable
  module Routing; end

  class << self
    def dependent_classes
      [Measure]
    end

    def route_concerns(mapper)
      mapper.concern :measureable do
        mapper.resources :measures, path: 'voorbeelden', only: %i[new index create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end