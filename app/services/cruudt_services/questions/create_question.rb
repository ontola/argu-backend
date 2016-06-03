
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

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end
end
