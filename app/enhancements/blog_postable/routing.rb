# frozen_string_literal: true

module BlogPostable
  module Routing; end

  class << self
    def dependent_classes
      [BlogPost]
    end

    def route_concerns(mapper)
      mapper.concern :blog_postable do
        mapper.resources :blog_posts, only: %i[index new create], path: 'posts' do
          mapper.collection do
            mapper.concerns :nested_actionable
          end
        end
      end
    end
  end
end
