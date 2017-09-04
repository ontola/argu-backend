# frozen_string_literal: true

class CreateQuestion < PublishedCreateService
  private

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end

  def parent_columns
    %i[forum_id project_id]
  end
end
