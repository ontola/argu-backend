# frozen_string_literal: true

module BlogPostable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :blog_posts, predicate: NS::ARGU[:blogPosts]
    end
  end
end
