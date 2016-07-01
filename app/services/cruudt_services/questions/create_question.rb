
class CreateQuestion < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    assign_forum_from_edge_tree
    resource.project_id = parent.owner_id if parent.owner_type == 'Project'
  end

  private

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end
end
