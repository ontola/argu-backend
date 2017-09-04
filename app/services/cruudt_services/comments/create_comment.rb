# frozen_string_literal: true

class CreateComment < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    attributes[:commentable_id] = parent.owner_id
    attributes[:commentable_type] = parent.owner_type
    super
  end
end
