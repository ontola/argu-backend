# frozen_string_literal: true

# Service for updating blog posts.
# @author Fletcher91 <thom@argu.co>
class UpdateDataset < EdgeableUpdateService
  private

  def object_attributes=(obj)
    return unless obj.is_a?(Activity)
    obj.owner ||= resource.creator
  end
end
