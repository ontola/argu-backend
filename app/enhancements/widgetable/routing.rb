# frozen_string_literal: true

module Widgetable
  module Routing
    class << self
      def dependent_classes
        [Widget]
      end

      def route_concerns(mapper)
        mapper.concern :widgetable do
          mapper.resources :widgets, only: %i[index new create] do
            mapper.collection do
              mapper.resources :action_items, path: 'actions', only: %i[index show], collection: :widgets
            end
          end
        end
      end
    end
  end
end
