# frozen_string_literal: true
module BlogPostable
  extend ActiveSupport::Concern

  included do
    has_many :blog_posts,
             as: :blog_postable,
             inverse_of: :blog_postable
  end

  module ClassMethods
  end
end
