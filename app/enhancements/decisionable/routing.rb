# frozen_string_literal: true

module Decisionable
  module Routing; end

  class << self
    def dependent_classes
      [Decision]
    end

    def route_concerns(mapper)
      mapper.concern :decisionable do
        mapper.resources :decisions, only: %i[new create index] do
          mapper.include_route_concerns
        end
      end
    end
  end
end
