# frozen_string_literal: true

class Favorite < ApplicationRecord
  include Parentable
  belongs_to :user
  belongs_to :edge
  validates :edge, presence: true, uniqueness: {scope: :user}

  parentable :forum

  after_create :follow_edge

  def follow_edge
    user.follow(edge, :news)
  end
end
