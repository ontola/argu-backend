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

  alias_attribute :happened_at, :created_at

  validates_presence_of :forum, :key, :trackable, :owner, :recipient

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

  def action
    key.split('.').last
  end

  def self.anonymize(collection)
    collection.update_all(owner_id: 0)
  end

  def object
    trackable_type.underscore
  end
end
