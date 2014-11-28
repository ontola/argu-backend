class Forum < ActiveRecord::Base
  extend FriendlyId

  belongs_to :page
  has_many :questions, inverse_of: :forum
  has_many :motions, inverse_of: :forum
  has_many :memberships
  accepts_nested_attributes_for :memberships

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

  def display_name
    name
  end

  def page=(value)
    super Page.friendly.find(value)
  end

  def self.first_public
    Forum.first
  end

  def tag_list=(value)
    super(value.downcase.strip)
  end
end
