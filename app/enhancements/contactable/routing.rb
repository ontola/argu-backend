# frozen_string_literal: true

module Contactable
  module Routing
    class << self
      def dependent_classes
        [DirectMessage]
      end

      def route_concerns(mapper)
        mapper.concern :contactable do
          mapper.resources :direct_messages, path: :dm, only: [:new]
        end
      end
    end
  end
end
