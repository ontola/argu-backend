module BlogPostable
  extend ActiveSupport::Concern

  included do
    has_many :blog_posts,
             -> {where(trashed_at: nil)},
             as: :blog_postable,
             inverse_of: :blog_postable
  end

  module ClassMethods
  end
end
