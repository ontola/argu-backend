class Forum < ActiveRecord::Base
  include ArguBase, Attribution, Shortnameable

  belongs_to :page
  has_many :questions, inverse_of: :forum
  has_many :motions, inverse_of: :forum
  has_many :arguments, inverse_of: :forum
  has_many :memberships
  has_many :members, through: :memberships, source: :profile
  accepts_nested_attributes_for :memberships
  has_many :managerships, -> { where(role: Membership.roles[:manager]) }, class_name: 'Membership'
  has_many :managers, through: :managerships, source: :profile
  has_many :votes, inverse_of: :forum
  has_many :moderators, -> { where(role: 2) }, class_name: 'Membership'
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :groups

  # @private
  # Used in the forum selector
  attr_accessor :is_checked, :tab, :active

  acts_as_ordered_taggable_on :tags
  mount_uploader :profile_photo, AvatarUploader
  process_in_background :profile_photo
  mount_uploader :cover_photo, CoverUploader
  acts_as_followable

  validates_integrity_of :profile_photo
  validates_processing_of :profile_photo
  validates_download_of :profile_photo
  validates :shortname, presence: true, length: {minimum: 4, maximum: 75}
  validates :name, presence: true, length: {minimum: 4, maximum: 75}
  validates :page_id, presence: true
  validates :bio, length: {maximum: 90}
  validates :bio_long, length: {maximum: 5000}

  after_validation :check_access_token, if: :visible_with_a_link_changed?

  # @!attribute visibility
  # @return [Enum] The visibility of the {Forum}
  enum visibility: {open: 1, closed: 2, hidden: 3} #unrestricted: 0,

  scope :public_forums, -> { where(visibility: Forum.visibilities[:open]) }
  scope :top_public_forums, ->(limit= 10) { where(visibility: Forum.visibilities[:open]).order('motions_count DESC').first(limit) }

  def access_token
    access_token! if self.visible_with_a_link
  end

  def access_token!
    AccessToken.where(item: self).first.try(:access_token)
  end

  def check_access_token
    if visible_with_a_link && access_token!.blank?
      AccessToken.create(item: self, profile: self.page.profile)
    end
  end

  def display_name
    name
  end

  def creator
    page.owner
  end

  def full_access_token
    AccessToken.where(item: self).first
  end

  def page=(value)
    super Page.find_via_shortname(value)
  end

  def profile_is_member?(profile)
    self.memberships.where(profile: profile).present?
  end

  # @return [Forum] based on the `:default_forum` {Setting}, if not present, the first Forum where {Forum#visibility} is `public`
  def self.first_public
    if (setting = Setting.get(:default_forum))
      forum = Forum.find_via_shortname(setting)
    end
    forum || Forum.public_forums.first
  end

  def featured_tags
    super.split(',')
  end

  def featured_tags=(value)
    super(value.downcase.strip)
  end
end
