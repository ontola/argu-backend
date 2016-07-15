# frozen_string_literal: true
class UpdateMotion < UpdateService
  include Wisper::Publisher

  def initialize(motion, attributes: {}, options: {})
    @motion = motion
    super
  end

  def resource
    @motion
  end

  private

  def object_attributes=(obj)
    obj.forum ||= @motion.forum
    obj.creator ||= @motion.creator
    obj.publisher ||= @motion.publisher if obj.respond_to?(:publisher)
  end
end
