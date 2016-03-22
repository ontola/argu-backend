
class CreateBlogPost < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @blog_post = profile.blog_posts.new
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @blog_post.publisher = profile.profileable
    end
    super
  end

  def resource
    @blog_post
  end
end
