
class CreateMotion < CreateService
  include Wisper::Publisher

  def initialize(motion, attributes = {}, options = {})
    @motion = motion
    super
  end

  def resource
    @motion
  end

  private

  def set_object_attributes(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
  end
end
