# frozen_string_literal: true

module BlogPostsHelper
  def blog_posts_title
    [
      t('blog_posts.type'),
      blog_post.published_at && "- #{l(blog_post.published_at)}"
    ].join
  end

  def blog_post_dateline(blog_post)
    if blog_post.published_at
      l(blog_post.published_at, format: :dateline)
    else
      t('blog_posts.unpublished')
    end
  end

  def date_for_publication(resource)
    if resource.argu_publication.published_at < Time.current + 12.hours
      time_ago_in_words(resource.argu_publication.published_at)
    else
      l(resource.argu_publication.published_at, format: :dateline)
    end
  end
end
