class FollowerCollectorBase

  def initialize(activity)
    @activity = activity
    @thing = activity.trackable
  end

end
