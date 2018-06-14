# frozen_string_literal: true

module Motionable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :motionable do
          mapper.resources :motions, path: 'm', only: %i[index new create]
        end
      end
    end
  end
end
