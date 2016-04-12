module BlogPostsHelper
  def blog_posts_title
    [
      t('blog_posts.type'),
      blog_post.published_at && "- #{l(blog_post.published_at)}"
    ].join
  end

  def blog_post_dateline(blog_post)
    if blog_post.is_published?
      l(blog_post.published_at, format: :dateline)
    else
      t('blog_posts.unpublished')
    end
  end
end
