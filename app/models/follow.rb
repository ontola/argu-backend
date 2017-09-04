# frozen_string_literal: true

class Follow < ApplicationRecord
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, class_name: 'Edge'
  belongs_to :follower, class_name: 'User'

  enum follow_type: {never: 0, decisions: 10, news: 20, reactions: 30}
  counter_culture :followable,
                  column_name: proc { |model|
                    !model.never? ? 'follows_count' : nil
                  },
                  column_names: {['follows.follow_type != ?', Follow.follow_types[:never]] => 'follows_count'}

  def block!
    update_attribute(:blocked, true)
  end
end
