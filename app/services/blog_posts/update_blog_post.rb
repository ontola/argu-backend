# Service for updating blog posts.
# @author Fletcher91 <thom@argu.co>
class UpdateBlogPost < UpdateService
  include Wisper::Publisher

  def initialize(blog_post, attributes = {}, options = {})
    @blog_post = blog_post
    super
  end

  def resource
    @blog_post
  end

  private

  def assign_attributes
    # TODO Filter out changes to manager, which should only be set on #new
    if @attributes[:happened_at].present?
      resource.happening.update(created_at: @attributes[:happened_at])
    end
    super
  end

  def object_attributes=(obj)
    obj.forum ||= @blog_post.forum
    obj.creator ||= @blog_post.creator
  end
end
