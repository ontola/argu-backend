# frozen_string_literal: true

class UpdateQuestion < EdgeableUpdateService
  private

  def object_attributes=(obj)
    obj.creator ||= resource.creator if obj.respond_to?(:creator)
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end
end
