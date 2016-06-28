
class CreateVote < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    resource.voteable = parent.owner
    resource.publisher.follow(@edge, nil, :news)
  end

  private

  def find_edge(parent, options)
    existing =
      parent
        .children.where(owner_type: 'Vote')
        .joins('JOIN votes ON edges.owner_id = votes.id')
        .find_by(votes: {voter_id: options.fetch(:creator).id})
    existing || super
  end
end
