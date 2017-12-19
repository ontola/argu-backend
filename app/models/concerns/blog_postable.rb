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
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :blog_post_collection, predicate: NS::ARGU[:blogPosts]
      # rubocop:enable Rails/HasManyOrHasOneDependent

      def blog_post_collection
        object.blog_post_collection(user_context: scope)
      end
    end
  end
end
