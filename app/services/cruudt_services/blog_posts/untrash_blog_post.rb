# frozen_string_literal: true
class UntrashBlogPost < UntrashService
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
  end
end
