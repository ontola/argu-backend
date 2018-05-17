# frozen_string_literal: true

module BlogPostable
  extend ActiveSupport::Concern

  included do
    has_many_through_edge :blog_posts

    with_collection :blog_posts, pagination: true
  end

  module ClassMethods
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :blog_posts, predicate: NS::ARGU[:blogPosts]
    end
  end
end
