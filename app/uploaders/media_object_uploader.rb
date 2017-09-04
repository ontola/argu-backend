# encoding: utf-8
# frozen_string_literal: true

require 'gravatar'

class MediaObjectUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay

  include CarrierWave::Vips

  ARCHIVE_TYPES = %w[application/zip].freeze
  DOCUMENT_TYPES = %w[application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
                      application/vnd.oasis.opendocument.text application/epub+zip].freeze
  IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze
  PORTABLE_DOCUMENT_TYPES = %w[application/pdf].freeze
  PRESENTATION_TYPES = %w[application/vnd.oasis.opendocument.presentation application/powerpoint
                          application/vnd.openxmlformats-officedocument.presentationml.presentation
                          application/vnd.openxmlformats-officedocument.presentationml.slideshow].freeze
  SPREADSHEET_TYPES = %w[text/csv application/excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                         text/comma-separated-values application/vnd.oasis.opendocument.spreadsheet].freeze

  if Rails.env.development? || Rails.env.test?
    storage :file
  else
    CarrierWave.configure do |config|
      config.storage    = :aws
      config.aws_bucket = 'argu-logos'
      config.aws_acl    = :public_read
      config.asset_host = 'https://argu-logos.s3.amazonaws.com'
      config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365

      config.aws_credentials = {
        access_key_id:     Rails.application.secrets.aws_id,
        secret_access_key: Rails.application.secrets.aws_key,
        region:            'eu-central-1'
      }
    end
    storage :aws
  end

  # Create different versions of your uploaded files:
  version :box, if: :is_image? do
    process convert: 'jpeg'
    process resize_to_limit: [568, 400]
  end

  version :cover, if: :cover_photo? do
    process convert: 'jpeg'
    process resize_to_limit: [1500, 600]
  end

  version :avatar, if: :is_image? do
    process convert: 'jpeg'
    process resize_to_fill: [256, 256]
  end

  version :icon, if: :is_image? do
    process convert: 'jpeg'
    process resize_to_fill: [64, 64]
  end

  def cover_photo?(_file = nil)
    model.cover_photo?
  end

  def default_url
    return unless profile_photo? && model.about.respond_to?(:email) && model.about.email.present?
    Gravatar.gravatar_url(model.about.email, size: '128x128', default: 'identicon')
  end

  def extension
    filename&.split('.')&.last
  end

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

  def is_image?(_file = nil)
    return true if profile_photo? || cover_photo?
    (content_type || model.content_type)&.split('/')&.first == 'image'
  end

  def profile_photo?(_file = nil)
    model.profile_photo?
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    case model.used_as.to_sym
    when :attachment
      "o/#{model.forum.page.id}/media_objects/#{model.id}"
    else
      "photos/#{model.id}"
    end
  end
end
