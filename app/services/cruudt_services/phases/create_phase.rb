# frozen_string_literal: true
class CreatePhase < PublishedCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
  end

  private

  def parent_columns
    %i(project_id forum_id)
  end
end
