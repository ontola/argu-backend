
# frozen_string_literal: true
class CreateComment < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    attributes[:commentable] = parent.owner
    super
  end
end
