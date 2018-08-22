# frozen_string_literal: true

module Statable
  module Routing
    class << self
      def dependent_classes
        [DirectMessage]
      end

      def route_concerns(mapper)
        mapper.concern :statable do
          mapper.get :statistics, to: 'statistics#show'
        end
      end
    end
  end
end
