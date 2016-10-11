# frozen_string_literal: true
class Follow < ApplicationRecord
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, class_name: 'Edge'
  belongs_to :follower, class_name: 'User'

  enum follow_type: {never: 0, decisions: 10, news: 20, reactions: 30}
  counter_culture [:followable, :forum],
                  column_name: proc { |model|
                    !model.never? && model.followable.owner_type == 'Forum' ? 'memberships_count' : nil
                  },
                  column_names: {['follows.follow_type != ? AND edges.owner_type = ?',
                                  Follow.follow_types[:never], 'Forum'] =>
                                   'memberships_count'}

  def block!
    update_attribute(:blocked, true)
  end
end
