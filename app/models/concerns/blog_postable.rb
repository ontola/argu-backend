# frozen_string_literal: true

module BlogPostable
  extend ActiveSupport::Concern

  included do
    has_many :blog_posts, as: :blog_postable, dependent: :destroy

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
