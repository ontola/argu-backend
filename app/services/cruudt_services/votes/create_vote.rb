# frozen_string_literal: true

class CreateVote < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    attributes[:voteable_id] = parent.owner.voteable.id
    attributes[:voteable_type] = parent.owner.voteable.class.base_class.name
    super
  end

  private

  def after_save
    super
    resource.publisher.follow(@edge, nil, :news)
    @edge.parent.reload if @edge.parent.persisted?
  end

  def existing_edge(parent, options, attributes)
    Edge.where_owner('Vote', for: attributes[:for], creator: options[:creator], primary: true).find_by(parent: parent)
  end

  def initialize_edge(parent, options, attributes)
    existing_edge(parent, options, attributes) || super
  end
end
