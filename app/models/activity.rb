# frozen_string_literal: true

class Activity < PublicActivity::Activity
  include Iriable
  include Ldable
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
  attr_accessor :silent

  validates :key, presence: true
  validates :trackable, :trackable_edge, :recipient, :recipient_edge, :owner,
            presence: {on: :create, if: proc { |a| a.trackable_type != 'Banner' && a.action != 'destroy' }}

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
      %w[blog_post motion question].include?(object)
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
    return if %w[destroy trash untrash].include?(action) || silent
    trackable_edge.touch(:last_activity_at) if trackable_edge&.persisted?
    recipient_edge.touch(:last_activity_at) if recipient_edge&.persisted? && !%w[Vote].include?(trackable_type)
  end
end
