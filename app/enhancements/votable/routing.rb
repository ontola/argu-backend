# frozen_string_literal: true

module Votable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :votable do
        mapper.resources :votes, only: %i[new create index]
        mapper.resource :vote, only: %i[show], path: :vote, vote_id: :shortcut do
          include_route_concerns(klass: Vote)
        end
      end
    end
  end
end
