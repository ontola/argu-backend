# frozen_string_literal: true

class UpdateComment < EdgeableUpdateService
  private

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
  end
end
