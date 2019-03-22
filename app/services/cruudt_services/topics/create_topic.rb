# frozen_string_literal: true

class CreateTopic < PublishedCreateService
  private

  def object_attributes=(obj)
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end
end
