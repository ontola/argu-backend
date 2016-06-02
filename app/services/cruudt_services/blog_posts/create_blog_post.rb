
class CreateBlogPost < PublishedCreateService
  include Wisper::Publisher

  def initialize(blog_post, attributes = {}, options = {})
    @blog_post = blog_post
    super
    resource.build_happening(forum: attributes[:forum],
                             created_at: attributes[:happened_at],
                             owner: resource.creator,
                             key: 'blog_post.happened',
                             recipient: resource.blog_postable) if attributes[:happened_at].present?
  end

  def resource
    @blog_post
  end

  private

  def object_attributes=(obj)
    if obj.is_a? Activity
      obj.created_at || DateTime.current
      obj.forum ||= resource.forum
      obj.owner ||= resource.creator
      obj.key ||= 'blog_post.happened'
      obj.recipient ||= resource.blog_postable
    end
  end
end
