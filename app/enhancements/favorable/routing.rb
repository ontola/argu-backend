# frozen_string_literal: true

module Favorable
  module Routing; end

  class << self
    def dependent_classes
      [Favorite]
    end

    def route_concerns(mapper)
      mapper.concern :favorable do
        mapper.resources :favorites, only: [:create]
        mapper.delete 'favorites', to: 'favorites#destroy'
      end
    end
  end
end
