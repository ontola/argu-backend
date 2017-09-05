# frozen_string_literal: true

# Service for creating a {Source}.
class CreateSource < PublishedCreateService
  private

  def object_attributes=(obj); end

  def parent_columns
    %i[page_id]
  end
end
