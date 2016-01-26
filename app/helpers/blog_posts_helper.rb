module BlogPostsHelper
  def blog_posts_title
    [
      t('blog_posts.type'),
      blog_post.published_at && "- #{l(blog_post.published_at)}"
    ].join
  end
end
