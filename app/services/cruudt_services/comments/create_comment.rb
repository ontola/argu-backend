
# frozen_string_literal: true
class CreateComment < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    attributes[:commentable] = parent.owner
    super
  end
end
