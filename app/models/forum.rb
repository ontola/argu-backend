class Forum < ActiveRecord::Base
  include ArguBase, Attribution
  extend FriendlyId

  belongs_to :page
  has_many :questions, inverse_of: :forum
  has_many :motions, inverse_of: :forum
  has_many :arguments, inverse_of: :forum
  has_many :memberships
  has_many :votes, inverse_of: :forum
  accepts_nested_attributes_for :memberships
  has_many :moderators, -> { where(role: 2) }, class_name: 'Membership'

  friendly_id :web_url, use: [:slugged, :finders]
  acts_as_ordered_taggable_on :tags

  mount_uploader :profile_photo, AvatarUploader
  process_in_background :profile_photo
  mount_uploader :cover_photo, CoverUploader
  acts_as_followable

  validates_integrity_of :profile_photo
  validates_processing_of :profile_photo
  validates_download_of :profile_photo
  validates :web_url, :name, presence: true, length: {minimum: 4}
  validates_format_of :web_url, with: /\A[a-zA-Z]\w{3,}/, message: '_moet met een letter beginnen_'
  validates :page_id, presence: true

  enum visibility: {open: 1, closed: 2, hidden: 3} #unrestricted: 0,

  scope :public_forums, -> { where(visibility: Forum.visibilities[:open]) }
  scope :top_public_forums, -> { where(visibility: Forum.visibilities[:open]).order('motions_count DESC').first(50) }

  def display_name
    name
  end

  def creator
    page.owner
  end

  def page=(value)
    super Page.friendly.find(value)
  end

  def self.first_public
    if (setting = Setting.get(:default_forum))
      forum = Forum.find_by(web_url: setting)
    end
    forum || Forum.public_forums.first
  end

  def featured_tags
    super.split(',')
  end

  def featured_tags=(value)
    super(value.downcase.strip)
  end

  def should_generate_new_friendly_id?
    web_url_changed?
  end
end
