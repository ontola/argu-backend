# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.development? || Rails.env.test?
    config.asset_host "https://#{Rails.application.config.host_name}"
  else
    config.storage    = :aws
    config.aws_bucket = ENV['AWS_BUCKET'] || 'argu-logos'
    config.asset_host = ENV['CARRIERWAVE_HOST'] || "https://#{ENV['AWS_BUCKET'] || 'argu-logos'}.s3.amazonaws.com"
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365

    config.aws_credentials = {
      access_key_id:     Rails.application.secrets.aws_id,
      secret_access_key: Rails.application.secrets.aws_key,
      region:            'eu-central-1'
    }
  end
end
