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

  validates :blog_postable, :creator, presence: true

  parentable :blog_postable, :forum
end
