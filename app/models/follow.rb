class Follow < ActiveRecord::Base
  include CounterChainable

  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, :polymorphic => true
  belongs_to :follower,   :polymorphic => true

  after_create :update_counter_chain
  after_destroy :update_counter_chain

  def block!
    self.update_attribute(:blocked, true)
  end

  def update_counter_chain
    if followable.respond_to? :update_counter_chain
      followable.update_counter_chain
    end
  end

end
