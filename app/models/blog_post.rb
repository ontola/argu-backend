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

  validates :blog_postable, :creator, presence: true
  validate :validate_within_project_scope

  parentable :blog_postable, :forum
  counter_culture :project,
                  column_name: proc { |model| model.is_published && !model.is_trashed? ? 'blog_posts_count' : nil }
  alias_attribute :description, :content
  alias_attribute :display_name, :title
  attr_accessor :happened_at
  delegate :happened_at, to: :happening, allow_nil: true

  def validate_within_project_scope
    if blog_postable.is_a?(Project) && published_at.present?
      if blog_postable.start_date > published_at ||
          (blog_postable.end_date.present? && blog_postable.end_date < published_at)
        errors.add(:published_at, 'must be published during a phase of the project')
      end
    end
  end
end
