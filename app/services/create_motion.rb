
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
      # Reload the motion to let the question_answers become active in the `through` relation
      @motion.reload
      @motion.publisher.follow(@motion) if @motion.publisher.present?
      publish(:create_motion_successful, @motion)
    end
  rescue ActiveRecord::RecordInvalid
    publish(:create_motion_failed, @motion)
  end

end
