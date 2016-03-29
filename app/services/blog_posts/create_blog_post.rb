
class CreateBlogPost < CreateService
  include Wisper::Publisher

  def initialize(blog_post, attributes = {}, options = {})
    @blog_post = blog_post
    super
  end

  def resource
    @blog_post
  end
end
