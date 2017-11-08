# frozen_string_literal: true

class Activity < PublicActivity::Activity
  include Iriable
  RELEVANT_KEYS = %w[vote.create question.publish motion.publish argument.create blog_post.publish
                     decision.approved decision.rejected comment.create].freeze
  has_many :notifications, dependent: :destroy
  # The creator of the activity
  # @example Create action
  #   Alice creates an argument against Bob's motion
  #   activity.owner # => Alice
  # @example Update
  #   Moderator updates Alice's argument
  #   activity.owner # => Moderator
  belongs_to :owner, class_name: 'Profile'
  belongs_to :trackable_edge, class_name: 'Edge', inverse_of: :activities
  belongs_to :recipient_edge, class_name: 'Edge', inverse_of: :recipient_activities
  belongs_to :forum

  alias_attribute :happened_at, :created_at
  alias context_id id

  validates :key, presence: true
  validates :trackable, :trackable_edge, :recipient, :recipient_edge, :owner,
            presence: {on: :create, if: proc { |a| a.trackable_type != 'Banner' && a.action != 'destroy' }}
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

  before_create :touch_edges

  def action
    key.split('.').last
  end

  # Hands over publication of a collection to the Community profile
  def self.anonymize(collection)
    collection.update_all(owner_id: Profile::COMMUNITY_ID)
  end

  def identifier
    "#{self.class.name.tableize}_#{id}"
  end

  def self.feed(relevant_only)
    scope = Activity
      .includes(:owner)
      .joins(:trackable_edge)
      .loggings
      .where('trackable_type != ?', 'Banner')
      .where('trackable_type != ? OR recipient_type != ?', 'Vote', 'Argument')
    return scope unless relevant_only
    scope
      .where('key IN (?)', RELEVANT_KEYS)
      .joins('LEFT JOIN votes ON votes.id = edges.owner_id AND edges.owner_type = \'Vote\'')
      .where('votes.id IS NULL OR (votes.explanation IS NOT NULL AND votes.explanation != \'\')')
  end

  def self.feed_for_edge(edge, filter_relevant = true)
    feed(filter_relevant)
      .where('edges.path <@ ?', edge.path)
  end

  def self.feed_for_favorites(favorites, filter_relevant = true)
    return Activity.none if favorites.empty?
    feed(filter_relevant)
      .where("edges.path ? #{Edge.path_array(favorites.joins(:edge).pluck(:path))}")
  end

  def self.feed_for_profile(profile, filter_relevant = true)
    feed(filter_relevant)
      .where(owner_id: profile.id)
  end

  # Used to find followers for the notifications generated for this activity and to set the type of these notifications
  # @note See Follow.follow_types, Publication.follow_types and Notification.notification_types
  # @return [String] The follow type
  def follow_type
    new_content? && trackable_edge.try(:argu_publication)&.follow_type || 'reactions'
  end

  def new_content?
    case action
    when 'create'
      %w[argument comment].include?(object)
    when 'publish'
      %w[blog_post project motion question].include?(object)
    when 'approved', 'rejected', 'forwarded'
      true
    else
      false
    end
  end

  def object
    trackable_type.underscore
  end

  def touch_edges
    return if %w[destroy trash untrash].include?(action)
    trackable_edge.touch(:last_activity_at) if trackable_edge&.persisted?
    recipient_edge.touch(:last_activity_at) if recipient_edge&.persisted? && !%w[Vote].include?(trackable_type)
  end

  private

  def validate_happening_within_project_scope
    return unless action == 'happened' && trackable.parent_model.is_a?(Project)
    return unless trackable.parent_model.start_date > created_at ||
        (trackable.parent_model.end_date.present? && trackable.parent_model.end_date < created_at)
    errors.add(:happened_at, 'must be published during a phase of the project')
  end
end
