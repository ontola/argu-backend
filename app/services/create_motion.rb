
class CreateMotion < ApplicationService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @motion = profile.motions.new(attributes)
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @motion.publisher = profile.profileable
    end
  end

  def resource
    @motion
  end

  def commit
    Motion.transaction do
      @motion.save!
      @motion.publisher.follow(@motion)
      publish(:create_motion_successful, @motion)
    end
  rescue ActiveRecord::RecordInvalid
    Bugsnag.notify(e)
    publish(:create_motion_failed, @motion)
  end

end
