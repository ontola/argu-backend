# frozen_string_literal: true

module Discussable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :discussable do
          mapper.concern :discussable do
            mapper.resources :discussions, only: %i[index new]
          end
        end
      end
    end
  end
end
