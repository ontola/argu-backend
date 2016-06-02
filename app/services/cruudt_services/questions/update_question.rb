class UpdateQuestion < UpdateService
  include Wisper::Publisher

  def initialize(question, attributes = {}, options = {})
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
  end
end
