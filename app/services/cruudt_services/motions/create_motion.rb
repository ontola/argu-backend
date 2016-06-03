
class CreateMotion < PublishedCreateService
  include Wisper::Publisher

  def initialize(motion, attributes = {}, options = {})
    @motion = motion
    super
  end

  def resource
    @motion
  end

  private

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end
end
