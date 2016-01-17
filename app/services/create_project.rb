# Service for the creation of projects
# @author Fletcher91 <thom@argu.co>
class CreateProject < ApplicationService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @project = profile.projects.new(attributes)
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @project.publisher = profile.profileable
    end
    set_nested_associations
  end

  def resource
    @project
  end

  def commit
    Project.transaction do
      @project.save!
      @project.publisher.follow(@project)
      publish(:create_project_successful, @project)
    end
  rescue ActiveRecord::RecordInvalid
    publish(:create_project_failed, @project)
  end

  private

  def set_object_attributes(obj)
    obj.forum ||= @project.forum
    obj.creator ||= @project.creator
  end

end
