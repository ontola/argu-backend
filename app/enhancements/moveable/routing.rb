# frozen_string_literal: true

module Moveable
  module Routing; end

  class << self
    def route_concerns(mapper)
      mapper.concern :moveable do
        resources :move, only: %i[new create], path: :move
      end
    end
  end
end
