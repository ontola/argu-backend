# Service for updating projects.
# @author Fletcher91 <thom@argu.co>
class UpdateProject < ApplicationService
  include Wisper::Publisher

  def initialize(project, attributes = {}, options = {})
    @project = project
    @attributes = attributes
    @actions = {}
    assign_attributes
    set_nested_associations
  end

  def resource
    @project
  end

  def commit
    Project.transaction do
      @actions[:updated] = @project.save!

      publish(:update_project_successful, @project) if @actions[:updated]
      publish(:publish_project_successful, @project) if @actions[:published]
      publish(:unpublish_project_successful, @project) if @actions[:unpublished]
    end
  rescue ActiveRecord::RecordInvalid
    publish(:update_project_failed, @project)
  end

  private

  def assign_attributes
    if @attributes.delete(:publish).to_s == 'true'
      @attributes[:published_at] = DateTime.current
      @actions[:published] = true
    end
    if @attributes.delete(:unpublish).to_s == 'true'
      @attributes[:published_at] = nil
      @actions[:unpublished] = true
    end
    @project.assign_attributes @attributes
  end

  def set_object_attributes(obj)
    obj.forum ||= @project.forum
    obj.creator ||= @project.creator
  end

end
