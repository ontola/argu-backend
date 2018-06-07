# frozen_string_literal: true

module Moveable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :moveable do
          mapper.member do
            mapper.get :move, action: :shift
            mapper.put :move, action: :move
          end
        end
      end
    end
  end
end
