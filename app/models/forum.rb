class Forum < ActiveRecord::Base
  include ArguBase, Attribution, Shortnameable, Flowable

  belongs_to :page
  has_many :access_tokens, inverse_of: :item, foreign_key: :item_id
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :arguments, inverse_of: :forum
  has_many :groups
  has_many :managerships, -> { where(role: Membership.roles[:manager]) }, class_name: 'Membership'
  has_many :managers, through: :managerships, source: :profile
  has_many :memberships
  has_many :members, through: :memberships, source: :profile
  accepts_nested_attributes_for :memberships
  has_many :moderators, -> { where(role: 2) }, class_name: 'Membership'
  has_many :motions, inverse_of: :forum
  has_many :questions, inverse_of: :forum
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'
  has_many :votes, inverse_of: :forum

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
  auto_strip_attributes :name, :cover_photo_attribution, :questions_title,
                        :questions_title_singular, :motions_title, :motions_title_singular,
                        :arguments_title, :arguments_title_singular, :squish => true
  auto_strip_attributes :featured_tags, squish: true, nullify: false
  auto_strip_attributes :bio, :nullify => false

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

  def m_access_tokens
    m_access_tokens! if self.visible_with_a_link
  end

  def m_access_tokens!
    AccessToken.where(item: self).pluck(:access_token)
  end

  def check_access_token
    if visible_with_a_link && access_token!.blank?
      self.access_tokens.build(item: self, profile: self.page.profile)
      #AccessToken.create(item: self, profile: self.page.profile)
    end
  end

  def creator
    page.owner
  end

  def display_name
    name
  end

  # http://schema.org/description
  def description
    self.bio
  end

  def self.find(*ids)
    shortname = ids.length == 1 && ids.first.instance_of?(String) && ids.first
    if (shortname && shortname.to_i == 0)
      find_via_shortname(shortname)
    else
      super(*ids)
    end
  end

  def full_access_token
    AccessToken.where(item: self).first
  end

  def page=(value)
    super value.is_a?(Page) ? value : Page.find_via_shortname(value)
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
