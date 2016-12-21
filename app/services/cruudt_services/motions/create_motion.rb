# frozen_string_literal: true
class CreateMotion < PublishedCreateService
  private

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end

  def parent_columns
    %i(question_id project_id forum_id)
  end
end
