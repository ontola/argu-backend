# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  unless Rails.env.development? || Rails.env.test?
    CarrierWave.configure do |config|
      config.storage    = :aws
      config.aws_bucket = 'argu-logos'
      config.aws_acl    = :public_read
      config.asset_host = 'https://argu-logos.s3.amazonaws.com'
      config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365

      config.aws_credentials = {
          access_key_id:     Rails.application.secrets.aws_id,
          secret_access_key: Rails.application.secrets.aws_key,
          region:            'eu-central-1',
          config: AWS.config({
                                 access_key_id:     Rails.application.secrets.aws_id,
                                 secret_access_key: Rails.application.secrets.aws_key,
                                 region:            'eu-central-1'
                             })
      }
    end
    storage :aws
  else
    storage :file
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.pluralize.underscore}/#{model.id}/avatar"
  end

  def default_url
    if model.respond_to?(:email) and model.email.present?
      Gravatar.gravatar_url(model.email, size: "128x128", default: 'identicon')
    end
  end

  # Create different versions of your uploaded files:
  version :icon do
    process :resize_to_fill => [64, 64, gravity= 'center']
  end

  version :avatar do
    process :resize_to_fill => [256, 256, gravity= 'center']
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png webp)
  end
end
