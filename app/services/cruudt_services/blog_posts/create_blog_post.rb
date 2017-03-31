
# frozen_string_literal: true
class CreateBlogPost < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    attributes[:blog_postable_id] = parent.owner_id
    attributes[:blog_postable_type] = parent.owner_type
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
      recipient: resource.parent_model,
      recipient_edge: resource.parent_model.edge,
      trackable_edge: resource.edge
    )
  end

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    if obj.is_a?(Activity)
      obj.created_at || DateTime.current
      obj.owner ||= resource.creator
      obj.key ||= 'blog_post.happened'
      obj.recipient ||= resource.parent_model
      obj.recipient_edge = obj.recipient.edge
      obj.trackable_edge = obj.trackable.edge
    else
      obj.creator ||= resource.creator
      obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
    end
  end
end
