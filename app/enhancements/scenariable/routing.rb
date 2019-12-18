# frozen_string_literal: true

module Scenariable
  module Routing; end

  class << self
    def dependent_classes
      [Scenario]
    end

    def route_concerns(mapper)
      mapper.concern :scenariable do
        mapper.resources :scenarios, only: %i[new index create] do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end
