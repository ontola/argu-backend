class Follow < ActiveRecord::Base
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, class_name: 'Edge'
  belongs_to :follower, class_name: 'User'

  enum follow_type: {never: 0, decisions: 10, news: 20, reactions: 30}

  def block!
    update_attribute(:blocked, true)
  end
end
