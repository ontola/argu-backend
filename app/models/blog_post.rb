class BlogPost < ActiveRecord::Base
  include ArguBase, Trashable, PublicActivity::Common, Flowable, Placeable,
          ActivePublishable, Parentable

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
             inverse_of: :blog_posts
  belongs_to :project,
             class_name: 'Project',
             foreign_key: :blog_postable_id

  has_many :activities,
           -> { where("key ~ '*.!happened'") },
           as: :trackable

  has_one :happening,
          -> { where("key ~ '*.happened'") },
          class_name: 'Activity',
          inverse_of: :trackable,
          as: :trackable,
          dependent: :destroy,
          autosave: true

  counter_culture :project,
                  column_name: proc { |model| model.is_published && !model.is_trashed? ? 'blog_posts_count' : nil }
  parentable :blog_postable, :forum

  validates :blog_postable, :creator, presence: true

  alias_attribute :description, :content
  alias_attribute :display_name, :title
  attr_accessor :happened_at
  delegate :happened_at, to: :happening, allow_nil: true
end
