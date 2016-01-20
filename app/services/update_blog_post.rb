# Service for updating blog posts.
# @author Fletcher91 <thom@argu.co>
class UpdateBlogPost < ApplicationService
  include Wisper::Publisher

  def initialize(blog_post, attributes = {}, options = {})
    @blog_post = blog_post
    @attributes = attributes
    @actions = {}
    assign_attributes
    set_nested_associations
  end

  def resource
    @blog_post
  end

  def commit
    Project.transaction do
      @actions[:updated] = @blog_post.save!

      publish(:update_blog_post_successful, @blog_post) if @actions[:updated]
      publish(:publish_blog_post_successful, @blog_post) if @actions[:published]
      publish(:unpublish_blog_post_successful, @blog_post) if @actions[:unpublished]
    end
  rescue ActiveRecord::RecordInvalid
    publish(:update_blog_post_failed, @blog_post)
  end

  private

  def assign_attributes
    if @attributes.delete(:publish).to_s == 'true'
      @attributes[:published_at] = DateTime.current
      @actions[:published] = true
    end
    if @attributes.delete(:unpublish).to_s == 'true'
      @attributes[:published_at] = nil
      @actions[:unpublished] = true
    end
    # TODO Filter out changes to manager, which should only be set on #new
    @blog_post.assign_attributes @attributes
  end

  def set_object_attributes(obj)
    obj.forum ||= @blog_post.forum
    obj.creator ||= @blog_post.creator
  end

end
