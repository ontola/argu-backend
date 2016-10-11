# frozen_string_literal: true
# Service for updating forums.
class UpdateForum < UpdateService
  include Wisper::Publisher

  def initialize(forum, attributes: {}, options: {})
    @forum = forum
    super
  end

  def resource
    @forum
  end

  private

  def object_attributes=(obj)
  end
end
