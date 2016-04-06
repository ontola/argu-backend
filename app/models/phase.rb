class Phase < ActiveRecord::Base
  include ArguBase, Placeable, Parentable
  attr_accessor :finish_phase

  belongs_to :forum
  belongs_to :project, inverse_of: :phases
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

  validates :forum, presence: true
  validates :project, presence: true
  validates :creator, presence: true

  # For Rails 5 attributes
  # attribute :name, :string
  # attribute :description, :text
  # attribute :integer, :position
  # attribute :start_date, :datetime
  # attribute :end_date, :datetime
  alias_attribute :display_name, :name

  parentable :project
  counter_culture :project

  def blog_posts
    return [] if start_date.nil?
    if end_date.present?
      project
        .blog_posts
        .where(published_at: start_date..end_date)
        .order(published_at: :asc)
    else
      project
          .blog_posts
          .where('published_at > ?', start_date)
          .order(published_at: :asc)
    end
  end
end
