# Service for updating blog posts.
# @author Fletcher91 <thom@argu.co>
class UpdateBlogPost < UpdateService
  include Wisper::Publisher

  def initialize(blog_post, attributes: {}, options: {})
    @blog_post = blog_post
    super
  end

  def resource
    @blog_post
  end

  private

  def object_attributes=(obj)
    return unless obj.is_a?(Activity)
    obj.forum ||= @blog_post.forum
    obj.owner ||= @blog_post.creator
  end
end
