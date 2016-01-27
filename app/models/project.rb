class Project < ActiveRecord::Base
  include ArguBase, Placeable, PublicActivity::Common, Flowable, Trashable,
          BlogPostable, ActivePublishable

  # For Rails 5 attributes
  # attribute :title, :string
  # attribute :content, :text
  # attribute :state, :integer, default: 0  # enum
  # attribute :start_date, :datetime
  # attribute :end_date, :datetime
  # attribute :achieved_end_date, :datetime
  # attribute :email, :string
  # attribute :trashed_at, :datetime

  alias_attribute :display_name, :title

  belongs_to :forum, inverse_of: :projects
  belongs_to :creator, class_name: 'Profile', inverse_of: :projects
  belongs_to :publisher, class_name: 'User'
  has_many   :phases, inverse_of: :project
  has_many   :stepups, as: :record

  accepts_nested_attributes_for :phases
  accepts_nested_attributes_for :stepups

  validates :forum, presence: true
  validates :creator, presence: true

  counter_culture :forum

  def latest_blog_post
    blog_posts.order(published_at: :desc).first
  end
end
