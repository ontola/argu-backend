# frozen_string_literal: true

require 'gravatar'

class MediaObjectUploader < CarrierWave::Uploader::Base
  include CarrierWave::Vips
  extend UrlHelper

  ARCHIVE_TYPES = %w[application/zip].freeze
  AUDIO_TYPES = %w[audio/mpeg audio/mp4 audio/m4a audio/ogg audio/aac].freeze
  DOCUMENT_TYPES = %w[application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
                      application/vnd.oasis.opendocument.text application/epub+zip text/plain].freeze
  IMAGE_TYPES = %w[image/jpeg image/png image/webp image/svg+xml].freeze
  PORTABLE_DOCUMENT_TYPES = %w[application/pdf].freeze
  PRESENTATION_TYPES = %w[application/vnd.oasis.opendocument.presentation application/powerpoint
                          application/vnd.openxmlformats-officedocument.presentationml.presentation
                          application/vnd.openxmlformats-officedocument.presentationml.slideshow].freeze
  SPREADSHEET_TYPES = %w[text/csv application/excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                         text/comma-separated-values application/vnd.oasis.opendocument.spreadsheet].freeze
  VIDEO_TYPES = %w[video/mp4].freeze
  EXTENSION_REGEX = IMAGE_TYPES
                      .map { |type| MIME::Types[type].map { |mime| mime.extensions.map { |ext| ".#{ext}" } } }
                      .flatten
                      .join('|')

  storage ENV['AWS_ID'].present? ? :aws : :file

  # Create different versions of your uploaded files:
  CONVERSION_OPTIONS = {
    interlace: true,
    optimize_coding: true,
    trellis_quant: true,
    optimize_scans: true,
    overshoot_deringing: true,
    quant_table: 3,
    quality: 75
  }.freeze
  IMAGE_VERSIONS = {
    icon: {if: :is_image?, w: 64, h: 64, strategy: :resize_to_fill, conversion_opts: {quant_table: 0, quality: 90}},
    avatar: {if: :is_image?, w: 256, h: 256, strategy: :resize_to_fill},
    box: {if: :is_image?, w: 568, h: 400, strategy: :resize_to_limit},
    cover: {if: :is_image?, w: 1500, h: 2000, strategy: :resize_to_limit, conversion_opts: {quality: 100}}
  }.freeze

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

  def content_type_white_list
    model.class.content_type_white_list
  end

  def cover_photo?(_file = nil)
    model.cover_photo?
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
  def extension_whitelist
    content_type_white_list.map { |type| MIME::Types[type].map(&:extensions).flatten.uniq }.flatten.uniq
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
