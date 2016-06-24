
class CreatePhase < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    assign_forum_from_edge_tree
  end

  def resource_klass
    Phase
  end
end
