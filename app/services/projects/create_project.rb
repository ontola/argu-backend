# Service for the creation of projects
# @author Fletcher91 <thom@argu.co>
class CreateProject < CreateService
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
    obj.forum ||= @project.forum
    obj.creator ||= @project.creator
  end
end
