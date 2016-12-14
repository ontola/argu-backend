
# frozen_string_literal: true
class CreateVote < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    attributes[:voteable_id] = parent.owner_id
    attributes[:voteable_type] = parent.owner_type
    super
  end

  private

  def after_save
    super
    resource.publisher.follow(@edge, nil, :news)
  end

  def initialize_edge(parent, options)
    existing =
      parent
      .children.where(owner_type: 'Vote')
      .joins('JOIN votes ON edges.owner_id = votes.id')
      .find_by(votes: {voter_id: options.fetch(:creator).id})
    existing || super
  end
end
