
class FollowersCollector
  def initialize(activity)
    @activity = activity
  end

  def call
    followers = @activity
                  .recipient
                  .edge
                  .followers(includes: {follower: :profile})
                  .uniq
                  .reject { |u| u.profile == @activity.owner }
    prepare_followers(followers)
  end

  private

  # @return [Array<Hash{Symbol => User, Symbol => Activity}>] List of attributes for {Notification} creation
  def prepare_followers(followers)
    followers
      .map { |f| {user: f, activity: @activity} }
  end
end
