# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  if ENV['GOOGLE_STORAGE_ACCESS_KEY_ID'].present? && ENV['GOOGLE_STORAGE_SECRET_ACCESS_KEY'].present?
    storage = :fog
    fog_credentials = {
        :provider                         => 'Google',
        :google_storage_access_key_id     => ENV['GOOGLE_STORAGE_ACCESS_KEY_ID'] || Rails.application.secrets.google_storage_access_key_id,
        :google_storage_secret_access_key => ENV['GOOGLE_STORAGE_SECRET_ACCESS_KEY'] || Rails.application.secrets.google_storage_secret_access_key
    }
    fog_directory = 'argu-logos'
  else
    storage = :local
  end


  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.pluralize.underscore}/#{model.id}-#{model.name.gsub(' ', '+')}"
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
  version :icon do
    process :resize_to_fit => [16, 16]
  end

  version :cover do
    process :resize_to_fit => [1500, 1000]
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