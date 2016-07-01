
class CreateArgument < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    assign_forum_from_edge_tree
    walk_parents
  end

  private

  def after_save
    super
    if @options[:auto_vote]
      ::CreateVote
        .new(
          resource.edge,
          attributes: {
            for: :pro,
            voter: resource.creator
          },
          options: {
            creator: resource.creator,
            publisher: resource.creator.profileable
          })
        .commit
    end
  end

  def walk_parents
    resource.motion = resource.edge.parent.owner
  end
end
