# frozen_string_literal: true

class CreateGroupResponse < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
  end

  private

  def parent_columns
    %i(motion_id forum_id)
  end
end
