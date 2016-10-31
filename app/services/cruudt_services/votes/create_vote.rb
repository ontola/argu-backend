
# frozen_string_literal: true
class CreateVote < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    super
    resource.voteable = parent.owner
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
