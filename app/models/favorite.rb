# frozen_string_literal: true
class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :edge

  after_create :follow_edge

  def follow_edge
    return if Follow.follow_types[:news] <= Follow.follow_types[user.following_type(edge)]
    user.follow(edge, :news)
  end
end
