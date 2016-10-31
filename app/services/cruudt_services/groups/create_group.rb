
# frozen_string_literal: true
class CreateGroup < EdgeableCreateService
  def initialize(parent, attributes: {}, options: {})
    raise 'The parent of a Group must be the Edge of a Page' unless parent.owner_type == 'Page'
    super
  end

  private

  def parent_columns
    %i(page_id)
  end
end
