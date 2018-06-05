# frozen_string_literal: true

class CreateBlogPost < PublishedCreateService
  def object_attributes=(obj)
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end
end
