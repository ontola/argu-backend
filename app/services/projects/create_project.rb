# Service for the creation of projects
# @author Fletcher91 <thom@argu.co>
class CreateProject < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @project = profile.projects.new
    super
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @project.publisher = profile.profileable
    end
  end

  def resource
    @project
  end

  private

  def set_object_attributes(obj)
    obj.forum ||= @project.forum
    obj.creator ||= @project.creator
  end
end
