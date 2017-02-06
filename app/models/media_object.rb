# frozen_string_literal: true
class MediaObject < ApplicationRecord
  include Ldable
  belongs_to :about, polymorphic: true, inverse_of: :media_objects
  belongs_to :forum
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

  mount_uploader :content, MediaObjectUploader, mount_on: :content_uid

  validates_integrity_of :content
  validates_processing_of :content
  validates_download_of :content

  enum used_as: {content_photo: 0, cover_photo: 1, profile_photo: 2, attachment: 3}

  delegate :url, :file, :icon, :avatar, to: :content

  contextualize_as_type 'schema:ImageObject'
  contextualize_with_id { |p| Rails.application.routes.url_helpers.root_url(protocol: :https) + "photos/#{p.id}" }
  contextualize :display_name, as: 'schema:name'
  contextualize :thumbnail, as: 'schema:thumbnail'

  # Hands over publication of a collection to the Community profile
  def self.anonymize(collection)
    collection.update_all(creator_id: Profile::COMMUNITY_ID)
  end

  # Hands over ownership of a collection to the Community user
  def self.expropriate(collection)
    collection.update_all(publisher_id: User::COMMUNITY_ID)
  end
end
