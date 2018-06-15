# frozen_string_literal: true

module Loggable
  module Routing
    class << self
      def route_concerns(mapper)
        mapper.concern :loggable do
          mapper.resource :log, only: %i[show], on: :member
        end
      end
    end
  end
end
