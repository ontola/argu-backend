# frozen_string_literal: true
class BlogPost < ApplicationRecord
  include Trashable, Flowable, Placeable, HasLinks, Loggable, PublicActivity::Common,
          ActivePublishable, Parentable, Happenable

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
  # @see {BlogPostable}
  belongs_to :blog_postable,
             polymorphic: true,
             required: true,
             inverse_of: :blog_posts
  belongs_to :project,
             class_name: 'Project',
             foreign_key: :blog_postable_id

  counter_culture :project,
                  column_name: proc { |model| model.is_published && !model.is_trashed? ? 'blog_posts_count' : nil },
                  column_names: {
                    ['blog_posts.is_published = ? AND blog_posts.trashed_at IS NULL', false] => 'blog_posts_count'
                  }
  parentable :blog_postable, :forum

  validates :content, presence: true, length: {minimum: 2}
  validates :title, presence: true, length: {minimum: 2, maximum: 110}
  validates :blog_postable, :creator, presence: true

  alias_attribute :description, :content
  alias_attribute :display_name, :title
  attr_accessor :happened_at
  delegate :happened_at, to: :happening, allow_nil: true

  # The amount of followers this blog_post will reach
  # @return [Integer] The number of followers
  def potential_audience
    blog_postable.edge.potential_audience(:news)
  end
end
