# Service for the creation of projects
# @author Fletcher91 <thom@argu.co>
class CreateProject < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
  end

  private

  def object_attributes=(obj)
    return if obj.is_a?(Publication)
    if obj.respond_to?(:edge)
      unless obj.edge
        obj.build_edge(
          parent: resource.edge,
          user: @options.fetch(:publisher))
      end
      obj.edge.parent ||= resource.edge
    end
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher unless obj.is_a?(Stepup)
  end
end
