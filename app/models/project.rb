class Project < ActiveRecord::Base
  include ArguBase, Placeable, PublicActivity::Common, Flowable, Trashable,
          BlogPostable, ActivePublishable, Parentable, Photoable

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
  has_many   :phases, -> {order(:id)}, inverse_of: :project
  has_many   :stepups, as: :record, dependent: :destroy
  has_many   :questions, inverse_of: :project
  has_many   :activities, as: :trackable

  accepts_nested_attributes_for :phases, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :stepups, reject_if: :all_blank, allow_destroy: true

  validates :forum, :creator, :start_date, presence: true

  before_save :update_start_date_of_first_phase
  counter_culture :forum
  acts_as_followable
  parentable :forum
  mount_uploader :cover_photo, CoverUploader

  def current_phase
    phases.where('start_date < ?', Time.now).last
  end

  def in_last_phase?
    phases.where('end_date IS NULL').count == 1
  end

  def latest_blog_post
    blog_posts.order(created_at: :desc).first
  end

  def update_start_date_of_first_phase
    if phases.present? && start_date_changed?
      if phases.first.persisted?
        phases.first.update!(start_date: start_date)
      else
        phases.first.start_date = start_date
      end
    end
  end
end
