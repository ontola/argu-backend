# frozen_string_literal: true

class CreateGroupResponse < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    assign_forum_from_edge_tree
    walk_parents
  end

  def resource_klass
    GroupResponse
  end

  private

  def walk_parents
    resource.motion = resource.edge.parent.owner
  end
end
