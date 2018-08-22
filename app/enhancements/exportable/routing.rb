# frozen_string_literal: true

module Exportable
  module Routing
    class << self
      def dependent_classes
        [Export]
      end

      def route_concerns(mapper)
        mapper.concern :exportable do
          mapper.resources :exports, only: %i[index create new]
        end
      end
    end
  end
end
