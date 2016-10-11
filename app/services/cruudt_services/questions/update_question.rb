# frozen_string_literal: true
class UpdateQuestion < UpdateService
  include Wisper::Publisher

  def initialize(question, attributes: {}, options: {})
    @question = question
    super
  end

  def resource
    @question
  end

  private

  def object_attributes=(obj)
    obj.forum ||= @question.forum
    obj.creator ||= @question.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end
end
