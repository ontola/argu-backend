# frozen_string_literal: true

class Favorite < ApplicationRecord
  include Parentable
  belongs_to :user
  belongs_to :edge, primary_key: :uuid
  validates :edge_id, presence: true, uniqueness: {scope: :user}

  parentable :forum

  after_create :follow_edge

  def edgeable_record
    @edgeable_record ||= edge.owner
  end

  def follow_edge
    user.follow(edge, :news)
  end

  def forum
    edge.owner if edge.owner_type == 'Forum'
  end
end
