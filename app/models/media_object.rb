# frozen_string_literal: true

require 'types/file_type'

class MediaObject < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include Parentable
  belongs_to :about, polymorphic: true, inverse_of: :media_objects, primary_key: :uuid
  belongs_to :forum, primary_key: :uuid
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

  mount_uploader :content, MediaObjectUploader, mount_on: :content_uid

  attribute :content, FileType.new
  validates :url, presence: true

  validates_integrity_of :content
  validates_processing_of :content
  validates_download_of :content

  enum used_as: {content_photo: 0, cover_photo: 1, profile_photo: 2, attachment: 3}
  filterable used_as: {values: MediaObject.used_as}
  counter_culture :about,
                  column_name: proc { |model|
                    model.attachment? ? 'attachments_count' : nil
                  },
                  column_names: {['media_objects.used_as = ?', MediaObject.used_as[:attachment]] => 'attachments_count'}

  delegate :file, :icon, :avatar, :is_image?, to: :content

  store_accessor :content_attributes, :position_y

  before_save :set_file_name
  before_save :set_publisher_and_creator

  alias edgeable_record about

  parentable :container_node, :question, :motion, :profile, :blog_post, :topic,
             :risk, :intervention, :intervention_type, :measure, :measure_type
  alias_attribute :display_name, :title

  # Hands over publication of a collection to the Community profile
  def self.anonymize(collection)
    collection.update_all(creator_id: Profile::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
  end

  # Hands over ownership of a collection to the Community user
  def self.expropriate(collection)
    collection.update_all(publisher_id: User::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
  end

  def allowed_content_types
    content.content_type_white_list
  end

  def content=(val)
    super unless val.is_a?(String)
  end

  def content_type
    content&.content_type
  rescue Aws::S3::Errors::NotFound
    Bugsnag.notify(RuntimeError.new("Aws::S3::Errors::NotFound: #{id}")) unless Rails.env.staging?
    nil
  end

  def content_type=(val); end

  delegate :embed_url, to: :video_info, allow_nil: true

  def parent
    about
  end

  def remote_content_url=(url)
    self.remote_url = url
    video_info ? super(video_info.thumbnail) : super
  end

  def thumbnail
    url_for_environment(:icon)
  end

  def thumbnail_or_icon # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    return thumbnail if file.nil?

    case content_type
    when *(MediaObjectUploader::IMAGE_TYPES + MediaObjectUploader::VIDEO_TYPES)
      thumbnail
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
    RDF::DynamicURI(type == 'video' ? remote_url : content.url(*args)).presence
  end

  def url_for_version(version)
    RDF::DynamicURI(path_with_hostname("#{root_relative_iri}/content/#{version}"))
  end

  private

  def set_file_name
    if video_info
      self.filename = video_info.title
    elsif content&.file.try(:original_filename).present?
      self.filename = content.file.original_filename
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def set_publisher_and_creator
    if creator.nil? && creator_id.nil? && about.present?
      self.creator = about.is_a?(Edge) ? about.creator : about.profile
    end
    return if publisher.present? || publisher_id.present?

    self.publisher = about.is_a?(Edge) ? about.publisher : creator.profileable
  end

  def url_for_environment(type)
    url = content.url(type)
    return url && RDF::DynamicURI(url) if ENV['AWS_ID'].present? || url&.to_s&.include?('gravatar.com')
    return if content.file.blank?

    if File.exist?(content.file.path)
      RDF::DynamicURI(content.url(:icon))
    else
      path = icon.path.gsub(File.expand_path(content.root), '')
      RDF::DynamicURI("https://#{ENV['AWS_BUCKET'] || 'argu-logos'}.s3.amazonaws.com#{path}")
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  def video_info
    return unless remote_url.present? && VideoInfo.usable?(remote_url)

    @video_info ||= VideoInfo.new(remote_url)
  end

  class << self
    def content_type_white_list
      MediaObjectUploader::ARCHIVE_TYPES +
        MediaObjectUploader::DOCUMENT_TYPES +
        MediaObjectUploader::IMAGE_TYPES +
        MediaObjectUploader::PORTABLE_DOCUMENT_TYPES +
        MediaObjectUploader::PRESENTATION_TYPES +
        MediaObjectUploader::SPREADSHEET_TYPES
    end
  end
end
