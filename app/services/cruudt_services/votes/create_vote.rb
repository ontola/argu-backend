
# frozen_string_literal: true
class CreateVote < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    attributes[:voteable_id] = parent.owner.voteable.id
    attributes[:voteable_type] = parent.owner.voteable.class.name
    super
  end

  private

  def after_save
    super
    resource.publisher.follow(@edge, nil, :news)
  end

  def existing_edge(parent, options)
    Edge.where_owner('Vote', creator: options[:creator]).find_by(parent: parent)
  end

  def initialize_edge(parent, options)
    existing_edge(parent, options) || super
  end
end
