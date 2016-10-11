# frozen_string_literal: true
class TrashMotion < TrashService
  include Wisper::Publisher

  def initialize(motion, attributes: {}, options: {})
    @motion = motion
    super
  end

  def resource
    @motion
  end
end
