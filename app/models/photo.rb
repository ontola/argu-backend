# frozen_string_literal: true
class Photo < ApplicationRecord
  include Ldable
  belongs_to :forum
  belongs_to :about, polymorphic: true, inverse_of: :photos
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

  mount_uploader :image, PhotoUploader, mount_on: :image_uid

  validates_integrity_of :image
  validates_processing_of :image
  validates_download_of :image

  enum used_as: {content_photo: 0, cover_photo: 1, profile_photo: 2}

  delegate :url, :file, :icon, :avatar, to: :image

  contextualize_as_type 'schema:ImageObject'
  contextualize_with_id { |p| Rails.application.routes.url_helpers.root_url(protocol: :https) + "photos/#{p.id}" }
  contextualize :display_name, as: 'schema:name'
  contextualize :thumbnail, as: 'schema:thumbnail'

  # Hands over publication of a collection to the Community profile (0)
  def self.anonymize(collection)
    collection.update_all(creator_id: 0)
  end

  # Hands over ownership of a collection to the Community user
  def self.expropriate(collection)
    collection.update_all(publisher_id: User::COMMUNITY_ID)
  end
end
