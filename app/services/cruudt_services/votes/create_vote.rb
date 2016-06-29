
class CreateVote < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super

    existing =
      parent
        .children.where(owner_type: 'Vote')
        .joins('JOIN votes ON edges.owner_id = votes.id')
        .find_by(votes: {voter_id: @options.fetch(:creator).id})
    if existing
      @edge = existing
      assign_attributes
    end

    assign_forum_from_edge_tree
    resource.voteable = parent.owner
  end

  def resource_klass
    Vote
  end
end
