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

  def set_object_attributes(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
  end
end
