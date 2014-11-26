class Forum < ActiveRecord::Base
  extend FriendlyId

  belongs_to :page
  has_many :questions, inverse_of: :forum
  has_many :motions, inverse_of: :forum
  has_many :memberships

  friendly_id :web_url, use: [:slugged, :finders]

  mount_uploader :profile_photo, ImageUploader
  mount_uploader :cover_photo, ImageUploader

  def display_name
    name
  end

  def page=(value)
    super Page.friendly.find(value)
  end
end
