# frozen_string_literal: true

module Moveable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :moveable do
          resources :move, only: %i[new create]
        end
      end
    end
  end
end
