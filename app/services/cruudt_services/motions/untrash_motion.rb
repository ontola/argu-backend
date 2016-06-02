class UntrashMotion < UntrashService
  include Wisper::Publisher

  def initialize(motion, options = {})
    @motion = motion
    super
  end

  def resource
    @motion
  end
end
