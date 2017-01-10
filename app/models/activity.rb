# frozen_string_literal: true
class Activity < PublicActivity::Activity
  has_many :notifications, dependent: :destroy
  # The creator of the activity
  # @example Create action
  #   Alice creates an argument against Bob's motion
  #   activity.owner # => Alice
  # @example Update
  #   Moderator updates Alice's argument
  #   activity.owner # => Moderator
  belongs_to :owner, class_name: 'Profile'
  belongs_to :forum

  attr_accessor :potential_action

  alias_attribute :happened_at, :created_at
  alias context_id id

  validates :forum, :key, :trackable, :owner, :recipient, presence: true
  validate :validate_happening_within_project_scope

  # Represents the physical event of the trackable.
  # @note A happening is an Activity with '*.happened' as key
  # @!attribute r created_at Indicates when the physical event took place.
  scope :happenings, -> { where("key ~ '*.happened'") }
  # Represents an activity of a {User} on Argu.
  # @!attribute r created_at Indicates when the {User}'s action was processed.
  # @example
  #     User created a {Motion}: key == 'motion.create'
  #     User updated an {Argument}: key == 'argument.update'
  scope :loggings, -> { where("key ~ '*.!happened'") }
  scope :since, ->(from_time = nil) { where('created_at < :from_time', from_time: from_time) if from_time.present? }
  scope :published, ->(show_unpublished = false) { show_unpublished ? all : where(is_published: true) }

  before_create :touch_edges

  def action
    key.split('.').last
  end

  # Hands over publication of a collection to the Community profile (0)
  def self.anonymize(collection)
    collection.update_all(owner_id: 0)
  end

  def identifier
    "#{self.class.name.tableize}_#{id}"
  end

  # Used to find followers for the notifications generated for this activity and to set the type of these notifications
  # @note See Follow.follow_types, Publication.follow_types and Notification.notification_types
  # @return [String] The follow type
  def follow_type
    trackable.try(:argu_publication)&.follow_type || 'reactions'
  end

  def object
    trackable_type.underscore
  end

  def self.published_for_user(user)
    if user.present?
      owner_ids = user.managed_pages.joins(:profile).pluck(:'profiles.id').append(user.profile.id)
      forum_ids = user.profile.forum_ids(:manager)
    end
    where('activities.is_published = true OR activities.owner_id IN (?) OR activities.forum_id IN (?)',
          owner_ids || [],
          forum_ids || [])
  end

  def touch_edges
    return if %w(destroy trash untrash).include?(action)
    trackable.edge.touch(:last_activity_at) if trackable.respond_to?(:edge) && trackable.edge.persisted?
    return unless recipient.respond_to?(:edge) && recipient.edge.persisted? && !%w(Vote).include?(trackable_type)
    recipient.edge.touch(:last_activity_at)
  end

  private

  def validate_happening_within_project_scope
    return unless action == 'happened' && trackable.parent_model.is_a?(Project)
    return unless trackable.parent_model.start_date > created_at ||
        (trackable.parent_model.end_date.present? && trackable.parent_model.end_date < created_at)
    errors.add(:happened_at, 'must be published during a phase of the project')
  end
end
