# frozen_string_literal: true
# Service for updating projects.
# @author Fletcher91 <thom@argu.co>
class UpdateProject < UpdateService
  include Wisper::Publisher

  def initialize(project, attributes: {}, options: {})
    @project = project
    super
  end

  def resource
    @project
  end

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
    obj.forum ||= @project.forum
    obj.creator ||= @project.creator
    obj.publisher ||= @project.publisher unless obj.is_a?(Stepup)
  end
end
