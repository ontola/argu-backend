# frozen_string_literal: true

module Convertible
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :convertible do
          resources :conversions, path: 'conversion', only: %i[new create]
        end
      end
    end
  end
end
