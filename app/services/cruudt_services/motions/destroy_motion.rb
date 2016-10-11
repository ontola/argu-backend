# frozen_string_literal: true
class DestroyMotion < DestroyService
  include Wisper::Publisher

  def initialize(motion, attributes: {}, options: {})
    @motion = motion
    super
  end

  def resource
    @motion
  end
end
