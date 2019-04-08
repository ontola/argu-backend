# frozen_string_literal: true

module Distributable
  module Routing
    class << self
      def dependent_classes
        [Distribution]
      end

      def route_concerns(mapper)
        mapper.concern :distributable do
          mapper.resources :distributions, only: %i[new create index]
        end
      end
    end
  end
end
