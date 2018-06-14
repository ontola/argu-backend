# frozen_string_literal: true

module Mediable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :mediable do
          mapper.resources :media_objects, only: :index
        end
      end
    end
  end
end
