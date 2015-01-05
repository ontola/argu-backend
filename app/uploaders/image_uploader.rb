# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  unless Rails.env.development? || Rails.env.test?
    CarrierWave.configure do |config|
      config.storage    = :aws
      config.aws_bucket = 'argu-logos'
      config.aws_acl    = :public_read
      config.asset_host = 'https://s3.amazonaws.com'
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
    "#{model.class.to_s.pluralize.underscore}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :box do
    process :resize_to_fit => [568, 400]
  end

  version :cover do
    process :resize_to_fit => [1500, 1000]
  end

  version :icon do
    process :resize_to_fit => [16, 16]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png webp)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end