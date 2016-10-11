
# frozen_string_literal: true
class CreateBlogPost < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    attributes[:blog_postable] = parent.owner
    super
    build_happening if attributes[:happened_at].present?
  end

  private

  def build_happening
    resource.build_happening(
      forum: resource.forum,
      created_at: @attributes[:happened_at],
      owner: resource.creator,
      key: 'blog_post.happened',
      recipient: resource.blog_postable
    )
  end

  def object_attributes=(obj)
    return unless obj.is_a? Activity
    obj.created_at || DateTime.current
    obj.forum ||= resource.forum
    obj.owner ||= resource.creator
    obj.key ||= 'blog_post.happened'
    obj.recipient ||= resource.blog_postable
  end
end
