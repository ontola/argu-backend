# frozen_string_literal: true

class Activity < PublicActivity::Activity
  include RailsLD::Model
  include Enhanceable
  has_many :notifications, dependent: :destroy
  # The creator of the activity
  # @example Create action
  #   Alice creates an argument against Bob's motion
  #   activity.owner # => Alice
  # @example Update
  #   Moderator updates Alice's argument
  #   activity.owner # => Moderator
  belongs_to :root, class_name: 'Edge', primary_key: :uuid
  belongs_to :owner, class_name: 'Profile'
  belongs_to :trackable,
             class_name: 'Edge',
             inverse_of: :activities,
             primary_key: :uuid,
             foreign_key: :trackable_edge_id
  belongs_to :recipient,
             class_name: 'Edge',
             inverse_of: :recipient_activities,
             primary_key: :uuid,
             foreign_key: :recipient_edge_id
  belongs_to :forum, primary_key: :uuid

  attr_accessor :silent

  validates :key, presence: true
  validates :trackable, :recipient, :owner,
            presence: {on: :create, if: proc { |a| a.action != 'destroy' }}

  alias edgeable_record trackable

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
    new_content? && trackable.try(:argu_publication)&.follow_type || 'reactions'
  end

  def new_content?
    case action
    when 'create'
      %w[con_argument pro_argument comment].include?(object)
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
    trackable.touch(:last_activity_at) if trackable&.persisted?
    recipient.touch(:last_activity_at) if recipient&.persisted? && !%w[Vote].include?(trackable_type)
  end
end
