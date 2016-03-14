class Project < ActiveRecord::Base
  include ArguBase, Placeable, PublicActivity::Common, Flowable, Trashable,
          BlogPostable, ActivePublishable, Parentable

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

  belongs_to :creator, class_name: 'Profile', inverse_of: :projects
  belongs_to :forum, inverse_of: :projects
  belongs_to :publisher, class_name: 'User'

  has_many   :motions, inverse_of: :project
  has_many   :phases, inverse_of: :project
  has_many   :stepups, as: :record, dependent: :destroy
  has_many   :questions, inverse_of: :project
  has_many :activities, as: :trackable

  accepts_nested_attributes_for :phases, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :stepups, reject_if: :all_blank, allow_destroy: true

  validates :forum, :creator, presence: true

  counter_culture :forum
  acts_as_followable
  parentable :forum

  def latest_blog_post
    blog_posts.order(published_at: :desc).first
  end
end
