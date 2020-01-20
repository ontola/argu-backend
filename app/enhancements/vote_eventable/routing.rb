# frozen_string_literal: true

module VoteEventable
  module Routing; end

  class << self
    def dependent_classes
      [VoteEvent]
    end

    def route_concerns(mapper)
      mapper.concern :vote_eventable do
        mapper.resources :vote_events, only: %i[index show], concerns: %i[votable] do
          mapper.include_route_concerns
        end
      end
    end
  end
end
