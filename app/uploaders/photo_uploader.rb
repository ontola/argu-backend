# encoding: utf-8
# frozen_string_literal: true
require 'gravatar'

class PhotoUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay

  include CarrierWave::Vips

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

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "photos/#{model.id}"
  end

  def default_url
    if model.profile_photo? && model.about.respond_to?(:email) && model.about.email.present?
      Gravatar.gravatar_url(model.about.email, size: '128x128', default: 'identicon')
    end
  end

  # Create different versions of your uploaded files:
  version :box do
    process convert: 'jpeg'
    process resize_to_fill: [568, 400]
  end

  version :cover do
    process convert: 'jpeg'
    process resize_to_fill: [1500, 600]
  end

  version :cover_small do
    process convert: 'jpeg'
    process resize_to_fill: [600, 300]
  end

  version :avatar do
    process convert: 'jpeg'
    process resize_to_fill: [256, 256]
  end

  version :icon do
    process convert: 'jpeg'
    process resize_to_fill: [64, 64]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png webp)
  end
end
