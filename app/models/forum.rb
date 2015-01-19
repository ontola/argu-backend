class Forum < ActiveRecord::Base
  include ArguBase
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

  mount_uploader :profile_photo, ImageUploader
  process_in_background :profile_photo
  mount_uploader :cover_photo, ImageUploader

  validates_integrity_of :profile_photo
  validates_processing_of :profile_photo
  validates_download_of :profile_photo
  validates :web_url, :name, presence: true, length: {minimum: 4}
  validates :page_id, presence: true

  enum visibility: {open: 1, closed: 2, hidden: 3} #unrestricted: 0,

  scope :public_forums, -> { where(visibility: Forum.visibilities[:open]) }
  scope :top_public_forums, -> { where(visibility: Forum.visibilities[:open]).order('motions_count DESC').first(50) }

  def display_name
    name
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
end
