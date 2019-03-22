# frozen_string_literal: true

module Topicable
  module Routing
    class << self
      def dependent_classes
        [Thread]
      end

      def route_concerns(mapper)
        mapper.concern :topicable do
          mapper.resources :topics, path: 't', only: %i[index new create] do
            mapper.collection do
              mapper.resources :action_items, path: 'actions', only: %i[index show], collection: :topics
            end
          end
        end
      end
    end
  end
end
