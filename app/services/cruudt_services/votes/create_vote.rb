
class CreateVote < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    assign_forum_from_edge_tree
    resource.voteable = parent.owner
  end

  def resource_klass
    Vote
  end
end
