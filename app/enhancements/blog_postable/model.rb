# frozen_string_literal: true

module BlogPostable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :blog_posts
    end
  end
end
