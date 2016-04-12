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
  validate :end_date_after_start_date

  # For Rails 5 attributes
  # attribute :name, :string
  # attribute :description, :text
  # attribute :integer, :position
  # attribute :start_date, :datetime
  # attribute :end_date, :datetime
  alias_attribute :display_name, :name

  before_save :update_date_of_project_or_next_phase

  parentable :project
  counter_culture :project

  def end_date_after_start_date
    if start_date.present? && end_date.present? && end_date < start_date
      errors.add(:end_date, "can't be before start date")
    end
  end

  def next_phase
    @next_phase ||= project.phases.where('id > ?', id).try(:first)
  end

  def previous_phase
    @previous_phase ||= project.phases.where('id < ?', id).try(:last)
  end

  def update_date_of_project_or_next_phase
    next_phase.present? ? next_phase.update!(start_date: end_date) : project.update!(end_date: end_date) if end_date_changed?
  end

  def blog_posts
    return [] if start_date.nil?
    if end_date.present?
      project
        .blog_posts
        .where(created_at: start_date..end_date)
        .where(is_published: true)
        .order(created_at: :asc)
    else
      project
        .blog_posts
        .where('created_at > ?', start_date)
        .where(is_published: true)
        .order(created_at: :asc)
    end
  end
end
