# frozen_string_literal: true

class CreateMotion < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    assign_forum_from_edge_tree
    if parent.owner_type == 'Question'
      resource.project_id = parent.parent.owner_id if parent.parent.owner_type == 'Project'
      resource.question_id = parent.owner_id
    elsif parent.owner_type == 'Project'
      resource.project_id = parent.owner_id
    end
  end

  def resource_klass
    Motion
  end

  private

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end
end
