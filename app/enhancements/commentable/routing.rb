# frozen_string_literal: true

module Commentable
  module Routing
    class << self
      def dependent_classes
        [Comment]
      end

      def route_concerns(mapper)
        mapper.concern :commentable do
          mapper.resources :comments, path: 'c', only: %i[new index show create] do
            mapper.collection do
              mapper.resources :action_items, path: 'actions', only: %i[index show], collection: :comments
            end
          end
          mapper.patch 'comments' => 'comments#create'
        end
      end
    end
  end
end
