# frozen_string_literal: true

class CreateBlogPost < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    super
    build_happening if attributes[:happened_at].present?
  end

  private

  def build_happening
    resource.build_happening(
      forum: resource.parent_model(:forum),
      created_at: @attributes[:happened_at],
      owner: resource.creator,
      key: 'blog_post.happened',
      recipient: resource.parent_model,
      recipient_type: resource.parent_model.to_s,
      trackable: resource,
      trackable_type: resource.class.to_s
    )
  end

  def object_attributes=(obj)
    if obj.is_a?(Activity)
      obj.created_at || Time.current
      obj.owner ||= resource.creator
      obj.key ||= 'blog_post.happened'
      obj.recipient ||= resource.parent_model
      obj.recipient_type ||= resource.parent.class.to_s
      obj.trackable_type ||= resource.class.to_s
    else
      obj.creator ||= resource.creator
      obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
    end
  end
end
