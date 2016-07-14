module BlogPostable
  extend ActiveSupport::Concern

  included do
    has_many :blog_posts,
             -> { where(trashed_at: nil) },
             as: :blog_postable,
             inverse_of: :blog_postable
    has_many :activities,
             -> { where("key ~ '*.!happened'") },
             as: :trackable
    has_many :happenings,
             -> { where("key ~ '*.happened'").order(created_at: :asc) },
             class_name: 'Activity',
             as: :recipient,
             inverse_of: :recipient do
      def published(show_unpublished = false)
        show_unpublished ? all : where(is_published: true)
      end
    end
  end

  # Fetches the latest published blog post which already happened.
  # @return [BlogPost, nil] The latest published blog post or nil if none exists
  def latest_blog_post(show_unpublished = false)
    base = show_unpublished ? blog_posts : blog_posts.published
    base
      .joins(:happening)
      .where('activities.created_at < ?', DateTime.current)
      .order('activities.created_at DESC')
      .references(:happening)
      .first
  end

  def published_happenings(show_unpublished = false)
    show_unpublished ? happenings : happenings.where(is_published: true)
  end

  module ClassMethods
  end
end
