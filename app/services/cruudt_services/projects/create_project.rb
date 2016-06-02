# Service for the creation of projects
# @author Fletcher91 <thom@argu.co>
class CreateProject < PublishedCreateService
  include Wisper::Publisher

  def initialize(project, attributes = {}, options = {})
    @project = project
    super
  end

  def resource
    @project
  end

  private

  def object_attributes=(obj)
    return if obj.is_a?(Publication)
    obj.forum ||= @project.forum
    obj.creator ||= @project.creator
    obj.publisher ||= @project.publisher unless obj.is_a?(Stepup)
  end
end
