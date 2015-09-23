
class CreateActivity < ApplicationService
  include Wisper::Publisher

  def initialize(profile, attributes = {})
    @activity = profile.activities.new(attributes)
  end

  def resource
    @activity
  end

  def commit
    if @activity.valid? && @activity.save
      publish(:create_activity_successful, @activity)
    else
      publish(:create_activity_failed, @activity)
    end
  end

end
