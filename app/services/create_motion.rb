
class CreateMotion < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @motion = profile.motions.new
    super
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @motion.publisher = profile.profileable
    end
  end

  def resource
    @motion
  end
end
