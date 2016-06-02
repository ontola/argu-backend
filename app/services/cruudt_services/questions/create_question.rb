
class CreateQuestion < PublishedCreateService
  include Wisper::Publisher

  def initialize(question, attributes = {}, options = {})
    @question = question
    super
  end

  def resource
    @question
  end

  private

  def set_object_attributes(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
  end
end
