# frozen_string_literal: true

module VoteEventable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :vote_eventable do
          mapper.resources :vote_events, only: %i[index show], concerns: %i[votable]
        end
      end
    end
  end
end
