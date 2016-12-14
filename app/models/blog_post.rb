# frozen_string_literal: true
class BlogPost < ApplicationRecord
  include Trashable, Flowable, Placeable, HasLinks, Loggable, PublicActivity::Common,
          ActivePublishable, Parentable, Happenable, Commentable

  # For Rails 5 attributes
  # attribute :state, :enum
  # attribute :title, :string
  # attribute :content, :text
  # attribute :trashed_at, :datetime
  # attribute :published_at, :datetime

  belongs_to :forum
  belongs_to :creator,
             class_name: 'Profile'
  belongs_to :publisher,
             class_name: 'User'

  counter_cache true
  parentable :motion, :question, :project

  validates :content, presence: true, length: {minimum: 2}
  validates :title, presence: true, length: {minimum: 2, maximum: 110}
  validates :creator, presence: true

  alias_attribute :description, :content
  alias_attribute :display_name, :title
  attr_accessor :happened_at
  delegate :happened_at, to: :happening, allow_nil: true

  # The amount of followers this blog_post will reach
  # @return [Integer] The number of followers
  def potential_audience
    parent_model.edge.potential_audience(:news)
  end
end
