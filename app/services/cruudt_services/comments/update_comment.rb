# frozen_string_literal: true
class UpdateComment < UpdateService
  include Wisper::Publisher

  def initialize(comment, attributes: {}, options: {})
    @comment = comment
    super
  end

  def resource
    @comment
  end

  private

  def object_attributes=(obj)
    obj.forum ||= @comment.forum
    obj.creator ||= @comment.creator
  end
end
