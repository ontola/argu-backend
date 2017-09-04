# frozen_string_literal: true

class CreatePhase < PublishedCreateService
  private

  def parent_columns
    %i(project_id forum_id)
  end
end
