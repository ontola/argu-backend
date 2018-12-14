# frozen_string_literal: true

module BlogPostable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :blog_posts
    end

    module ClassMethods
      def show_includes
        super + [
          blog_post_collection: inc_shallow_collection
        ]
      end
    end
  end
end
