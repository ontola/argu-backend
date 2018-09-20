# frozen_string_literal: true

require 'gravatar'

class MediaObjectUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay
  include CarrierWave::Vips
  extend UrlHelper

  ARCHIVE_TYPES = %w[application/zip].freeze
  DOCUMENT_TYPES = %w[application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
                      application/vnd.oasis.opendocument.text application/epub+zip text/plain].freeze
  IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze
  PORTABLE_DOCUMENT_TYPES = %w[application/pdf].freeze
  PRESENTATION_TYPES = %w[application/vnd.oasis.opendocument.presentation application/powerpoint
                          application/vnd.openxmlformats-officedocument.presentationml.presentation
                          application/vnd.openxmlformats-officedocument.presentationml.slideshow].freeze
  SPREADSHEET_TYPES = %w[text/csv application/excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                         text/comma-separated-values application/vnd.oasis.opendocument.spreadsheet].freeze
  VIDEO_TYPES = %w[video/mp4].freeze

  if ENV['AWS_ID'].blank?
    storage :file
  else
    storage :aws
  end

  # Create different versions of your uploaded files:
  VERSIONS = {
    icon: {if: :is_image?, w: 64, h: 64, strategy: :resize_to_fill},
    avatar: {if: :is_image?, w: 256, h: 256, strategy: :resize_to_fill},
    box: {if: :is_image?, w: 568, h: 400, strategy: :resize_to_limit},
    cover: {if: :cover_photo?, w: 1500, h: 600, strategy: :resize_to_limit}
  }
  VERSIONS.each do |type, opts|
    version type, if: opts[:if] do
      process convert: 'jpeg'
      process opts[:strategy] => [opts[:w], opts[:h]]
    end
  end

  def aws_acl
    public_content? ? 'public-read' : 'private'
  end

  def aws_signer
    return if ENV['AWS_ID'].blank? || public_content?
    lambda do |unsigned_url, _options|
      signer = Aws::S3::Presigner.new
      key = URI.parse(unsigned_url).path
      key.slice!(0)
      signer.presigned_url(:get_object, bucket: ENV['AWS_BUCKET'] || 'argu-logos', key: key)
    end
  end

  def cover_photo?(_file = nil)
    model.cover_photo?
  end

  def default_url
    return unless profile_photo?
    email =
      if model.about.try(:profileable_type) == 'Page'
        'anonymous'
      else
        "#{model.about_type}_#{model.about_id}@gravatar.argu.co"
      end
    Gravatar.gravatar_url(email, size: '128x128', default: 'identicon')
  end

  def extension
    filename&.split('.')&.last
  end

  def is_image?(_file = nil)
    return true if profile_photo? || cover_photo?
    content_type&.split('/')&.first == 'image'
  end

  def profile_photo?(_file = nil)
    model.profile_photo?
  end

  private

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    content_type_white_list.map { |type| MIME::Types[type].map(&:extensions).flatten.uniq }.flatten.uniq
  end

  def content_type_white_list
    case model.used_as.to_sym
    when :attachment
      MediaObjectUploader::ARCHIVE_TYPES +
        MediaObjectUploader::DOCUMENT_TYPES +
        MediaObjectUploader::IMAGE_TYPES +
        MediaObjectUploader::PORTABLE_DOCUMENT_TYPES +
        MediaObjectUploader::PRESENTATION_TYPES +
        MediaObjectUploader::SPREADSHEET_TYPES
    else
      MediaObjectUploader::IMAGE_TYPES
    end
  end

  def public_content?
    model.profile_photo?
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    case model.used_as.to_sym
    when :attachment
      "media_objects/#{model.id}"
    else
      "photos/#{model.id}"
    end
  end
end
