
class CreateBlogPost < CreateService
  include Wisper::Publisher

  def initialize(blog_post, attributes = {}, options = {})
    @blog_post = blog_post
    super
    resource.build_happening(forum: attributes[:forum],
                             created_at: attributes[:happened_at],
                             owner: resource.creator,
                             key: 'blog_post.happened',
                             recipient: resource.blog_postable)
  end

  def resource
    @blog_post
  end
end
