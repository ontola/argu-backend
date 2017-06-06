# frozen_string_literal: true
# Service for the creation of projects
# @author Fletcher91 <thom@argu.co>
class CreateProject < PublishedCreateService
  private

  def object_attributes=(obj)
    return if obj.is_a?(Publication)
    if obj.respond_to?(:edge)
      unless obj.edge
        obj.build_edge(
          parent: resource.edge,
          user: @options.fetch(:publisher)
        )
      end
      obj.edge.parent ||= resource.edge
    end
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher
  end
end
