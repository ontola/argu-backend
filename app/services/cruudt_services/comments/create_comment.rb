
class CreateComment < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    assign_forum_from_edge_tree
    walk_parents
  end

  private

  def walk_parents
    resource.commentable = resource.edge.parent.owner
  end
end
