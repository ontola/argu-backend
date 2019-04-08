# frozen_string_literal: true

module Datasettable
  module Routing
    class << self
      def dependent_classes
        [Dataset]
      end

      def route_concerns(mapper)
        mapper.concern :datasettable do
          mapper.resources :datasets, only: %i[new create index]
        end
      end
    end
  end
end
