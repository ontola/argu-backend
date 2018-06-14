# frozen_string_literal: true

module Questionable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :questionable do
          mapper.resources :questions, path: 'q', only: %i[index new create]
        end
      end
    end
  end
end
