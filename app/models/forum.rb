class Forum < ActiveRecord::Base
  include ArguBase, Attribution, Edgeable, Shortnameable, Flowable, Parentable, Photoable,
          ProfilePhotoable

  belongs_to :page, inverse_of: :forums
  has_many :access_tokens, inverse_of: :item, foreign_key: :item_id, dependent: :destroy
  has_many :activities, as: :trackable
  has_many :banners, inverse_of: :forum
  has_many :groups, dependent: :destroy
  has_many :managerships, -> { where(role: Membership.roles[:manager]) }, class_name: 'Membership'
  has_many :managers, through: :managerships, source: :profile
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :profile
  accepts_nested_attributes_for :memberships
  has_many :moderators, -> { where(role: 2) }, class_name: 'Membership'
  has_many :shortnames, inverse_of: :forum
  has_many :stepups, inverse_of: :forum
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'
  has_many :votes, inverse_of: :forum
  # User content
  has_many :arguments, inverse_of: :forum, dependent: :destroy
  has_many :motions, inverse_of: :forum, dependent: :destroy
  has_many :projects, inverse_of: :forum, dependent: :destroy
  has_many :questions, inverse_of: :forum, dependent: :destroy

  # @private
  # Used in the forum selector
  attr_accessor :is_checked, :tab, :active

  acts_as_ordered_taggable_on :tags
  paginates_per 30
  parentable :page

  validates :shortname, presence: true, length: {minimum: 4, maximum: 75}
  validates :name, presence: true, length: {minimum: 4, maximum: 75}
  validates :page_id, presence: true
  validates :bio, length: {maximum: 90}
  validates :bio_long, length: {maximum: 5000}
  validate :shortnames_count

  def shortnames_count
    errors.add(:shortnames, 'bad') if shortnames.count > max_shortname_count
  end

  after_validation :check_access_token, if: :visible_with_a_link_changed?
  auto_strip_attributes :name, :cover_photo_attribution, :questions_title,
                        :questions_title_singular, :motions_title, :motions_title_singular,
                        :arguments_title, :arguments_title_singular, squish: true
  auto_strip_attributes :featured_tags, squish: true, nullify: false
  auto_strip_attributes :bio, nullify: false

  # @!attribute visibility
  # @return [Enum] The visibility of the {Forum}
  enum visibility: {open: 1, closed: 2, hidden: 3} #unrestricted: 0,

  scope :top_public_forums,
        ->(limit = 10) { where(visibility: Forum.visibilities[:open]).order('memberships_count DESC').first(limit) }
  scope :public_forums, -> { where(visibility: Forum.visibilities[:open]).order('memberships_count DESC') }

  def access_token
    access_token! if visible_with_a_link
  end

  def access_token!
    access_tokens.first.try(:access_token)
  end

  def m_access_tokens
    m_access_tokens! if visible_with_a_link
  end

  def m_access_tokens!
    access_tokens.map(&:access_token)
  end

  def check_access_token
    return unless visible_with_a_link && access_token!.blank?
    access_tokens.build(item: self, profile: page.profile)
  end

  def creator
    page.owner
  end

  def display_name
    name
  end

  # http://schema.org/description
  def description
    bio
  end

  def self.find(*ids)
    shortname = ids.length == 1 && ids.first.instance_of?(String) && ids.first
    if shortname && shortname.to_i == 0
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
    memberships.where(profile: profile).present?
  end

  def publisher
    page.owner.profileable
  end

  # @return [Forum] based on the `:default_forum` {Setting}, if not present,
  # the first Forum where {Forum#visibility} is `public`
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

  # Is the forum out of its shortname limit
  # @see {max_shortname_count}
  # @return [Boolean] True if the forum has reached its maximum shortname count.
  def shortnames_depleted?
    shortnames.count >= max_shortname_count
  end
end
