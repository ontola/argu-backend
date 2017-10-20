# frozen_string_literal: true

class MediaObject < ApplicationRecord
  include Ldable
  include Parentable
  belongs_to :about, polymorphic: true, inverse_of: :media_objects
  belongs_to :forum
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

  mount_uploader :content, MediaObjectUploader, mount_on: :content_uid

  validates_integrity_of :content
  validates_processing_of :content
  validates_download_of :content

  enum used_as: {content_photo: 0, cover_photo: 1, profile_photo: 2, attachment: 3}
  filterable used_as: {values: MediaObject.used_as}

  delegate :file, :icon, :avatar, :is_image?, to: :content

  contextualize_as_type 'schema:MediaObject'
  contextualize_with_id do |p|
    Rails.application.routes.url_helpers.root_url(protocol: :https) + "media_objects/#{p.id}"
  end
  contextualize :display_name, as: 'schema:name'
  contextualize :thumbnail, as: 'schema:thumbnail'
  store_accessor :content_attributes

  before_save :set_file_name
  before_save :set_publisher_and_creator

  parentable :forum, :question, :motion, :profile
  alias parent_model about

  # Hands over publication of a collection to the Community profile
  def self.anonymize(collection)
    collection.update_all(creator_id: Profile::COMMUNITY_ID)
  end

  # Hands over ownership of a collection to the Community user
  def self.expropriate(collection)
    collection.update_all(publisher_id: User::COMMUNITY_ID)
  end

  def content_type
    content&.content_type
  rescue Aws::S3::Errors::NotFound
    Bugsnag.notify(RuntimeError.new("Aws::S3::Errors::NotFound: #{context_id}"))
    nil
  end

  def context_type
    is_image? ? 'schema:ImageObject' : 'schema:MediaObject'
  end

  delegate :embed_url, to: :video_info, allow_nil: true

  def remote_content_url=(url)
    self.remote_url = url
    video_info ? super(video_info.thumbnail) : super
  end

  def thumbnail
    case content_type
    when *MediaObjectUploader::IMAGE_TYPES
      content.icon.url
    when *MediaObjectUploader::VIDEO_TYPES
      content.icon.url
    when *MediaObjectUploader::PORTABLE_DOCUMENT_TYPES
      'file-pdf-o'
    when *MediaObjectUploader::DOCUMENT_TYPES
      'file-word-o'
    when *MediaObjectUploader::ARCHIVE_TYPES
      'file-archive-o'
    when *MediaObjectUploader::SPREADSHEET_TYPES
      'file-excel-o'
    when *MediaObjectUploader::PRESENTATION_TYPES
      'file-powerpoint-o'
    else
      'file-o'
    end
  end

  def type
    video_info ? 'video' : content_type&.split('/')&.first
  end

  def url(*args)
    type == 'video' ? remote_url : content.url(*args)
  end

  private

  def set_file_name
    if video_info
      self.filename = video_info.title
    elsif content&.file.try(:original_filename).present?
      self.filename = content.file.original_filename
    end
  end

  def set_publisher_and_creator
    self.creator = about if creator.nil? && creator_id.nil? && about.present?
    self.publisher = creator.profileable if publisher.nil? && publisher_id.nil? && creator.profileable.present?
  end

  def video_info
    return unless remote_url.present? && VideoInfo.usable?(remote_url)
    @video_info ||= VideoInfo.new(remote_url)
  end
end
