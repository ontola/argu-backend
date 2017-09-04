# frozen_string_literal: true

class CreateForum < EdgeableCreateService
  private

  def object_attributes=(obj)
  end

  def parent_columns
    %i[page_id]
  end
end
