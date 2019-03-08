# frozen_string_literal: true

module BlogPostable
  module Routing
    class << self
      def dependent_classes
        [BlogPost]
      end

      def route_concerns(mapper)
        mapper.concern :blog_postable do
          mapper.resources :blog_posts, only: %i[index new create], path: 'posts' do
            mapper.collection do
              mapper.resources :action_items, path: 'actions', only: %i[index show], collection: :blog_posts
            end
          end
        end
      end
    end
  end
end
