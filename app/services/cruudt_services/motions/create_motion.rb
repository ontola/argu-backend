# frozen_string_literal: true

class CreateMotion < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    if parent.owner_type == 'Question'
      resource.project_id = parent.parent.owner_id if parent.parent.owner_type == 'Project'
      resource.question_id = parent.owner_id
    elsif parent.owner_type == 'Project'
      resource.project_id = parent.owner_id
    end
  end

  private

  def after_save
    super
    resource.question.touch if resource.question.present?
    resource.project.touch if resource.project.present?
  end

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end

  def parent_columns
    %i(question_id project_id forum_id)
  end
end
