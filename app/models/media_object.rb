# frozen_string_literal: true

require 'types/file_type'

class MediaObject < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include Parentable
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance Cacheable
  include Broadcastable

  belongs_to :about, polymorphic: true, inverse_of: :media_objects, primary_key: :uuid
  belongs_to :forum, primary_key: :uuid
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  collection_options(
    display: :table
  )

  mount_uploader :content_old, MediaObjectUploader, mount_on: :content_uid
  has_one_attached :content do |attachable|
    MediaObjectUploader::IMAGE_VERSIONS.each do |type, opts|
      attachable.variant(
        type,
        opts[:strategy] => [opts[:w], opts[:h]],
        format: :jpeg,
        saver: MediaObjectUploader::CONVERSION_OPTIONS.merge(opts[:conversion_opts] || {})
      )
    end
  end

  with_columns default: [
    NS.dbo[:filename],
    NS.schema.uploadDate,
    NS.argu[:copyUrl],
    NS.ontola[:destroyAction]
  ]

  enum content_source: {local: 0, remote: 1}
  enum used_as: {content_photo: 0, cover_photo: 1, profile_photo: 2, attachment: 3}

  counter_culture :about,
                  column_name: proc { |model|
                    model.attachment? ? 'attachments_count' : nil
                  },
                  column_names: {['media_objects.used_as = ?', MediaObject.used_as[:attachment]] => 'attachments_count'}

  delegate :file, :icon, :avatar, to: :content

  store_accessor :content_attributes, :position_y
  attr_writer :content_source

  before_save :set_file_name
  before_save :set_publisher_and_creator

  alias edgeable_record about

  parentable :container_node, :question, :motion, :profile, :blog_post, :topic,
             :intervention, :intervention_type, :measure, :page
  alias_attribute :display_name, :title

  def allowed_content_types
    content.content_type_white_list
  end

  def content=(val)
    super unless val.is_a?(String) && val.include?('http')
  end

  def content_source
    remote_url.present? ? :remote : :local
  end

  def content_type
    return 'image/png' if gravatar_url?

    content&.content_type
  rescue Aws::S3::Errors::NotFound
    Bugsnag.notify(RuntimeError.new("Aws::S3::Errors::NotFound: #{id}")) unless Rails.env.staging?
    nil
  end

  def content_type=(val); end

  delegate :embed_url, to: :video_info, allow_nil: true

  def gravatar_url?
    content.blank? && profile_photo?
  end

  def parent
    about
  end

  def remote_content_url=(url)
    self.remote_url = url

    image_url = video_info ? video_info.thumbnail : url

    content.attach(io: URI.open(image_url), filename: video_info&.title || url.split('/').last)
  end

  def thumbnail
    public_url_for_version(:icon)
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
    when *MediaObjectUploader::AUDIO_TYPES
      'file-audio-o'
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

  # Generates the variant if not present yet
  def private_url_for_version(type)
    return gravatar_url if gravatar_url?

    return if content.blank?

    return RDF::URI(content.url) if type == :content

    RDF::URI(content.variant(type.to_sym).processed.url)
  end

  def public_url_for_version(version = :content)
    RDF::DynamicURI(path_with_hostname("#{root_relative_iri}/content/#{version}?version=#{updated_at.to_i}"))
  end

  private

  def gravatar_url
    email = about.is_a?(Page) ? 'anonymous' : "#{about_type}_#{about_id}@gravatar.argu.co"
    RDF::URI(Gravatar.gravatar_url(email, size: '128x128', default: 'identicon'))
  end

  def set_file_name
    new_filename = video_info&.title || content&.filename

    self.filename = new_filename if new_filename
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def set_publisher_and_creator
    if creator.nil? && creator_id.nil? && about.present?
      self.creator = about.is_a?(Edge) ? about.creator : about.profile
    end
    return if publisher.present? || publisher_id.present?

    self.publisher = about.is_a?(Edge) ? about.publisher : creator.profileable
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  def video_info
    @video_info ||= VideoInfo.new(remote_url) if VideoInfo.usable?(remote_url)
  end

  class << self
    # Hands over publication of a collection to the Community profile
    def anonymize(collection)
      collection.update_all(creator_id: Profile::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
    end

    def attributes_for_new(opts)
      super.merge(
        about: opts[:parent]
      )
    end

    def collection_from_parent_name(_parent, params)
      return super if params[:used_as].blank?

      "#{params[:used_as]}_collection"
    end

    def content_type_white_list
      MediaObjectUploader::ARCHIVE_TYPES +
        MediaObjectUploader::AUDIO_TYPES +
        MediaObjectUploader::DOCUMENT_TYPES +
        MediaObjectUploader::IMAGE_TYPES +
        MediaObjectUploader::PORTABLE_DOCUMENT_TYPES +
        MediaObjectUploader::PRESENTATION_TYPES +
        MediaObjectUploader::SPREADSHEET_TYPES
    end

    # Hands over ownership of a collection to the Community user
    def expropriate(collection)
      collection.update_all(publisher_id: User::COMMUNITY_ID) # rubocop:disable Rails/SkipsModelValidations
    end

    def iri
      NS.schema.MediaObject
    end
  end
end
