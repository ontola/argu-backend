
class CreateBlogPost < ApplicationService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @blog_post = profile.blog_posts.new(attributes)
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @blog_post.publisher = profile.profileable
    end
  end

  def resource
    @blog_post
  end

  def commit
    BlogPost.transaction do
      @blog_post.save!
      @blog_post.publisher.follow(@blog_post) if @blog_post.publisher.present?
      publish(:create_blog_post_successful, @blog_post)
    end
  rescue ActiveRecord::RecordInvalid
    publish(:create_blog_post_failed, @blog_post)
  end

end
