# frozen_string_literal: true

class ExportUploader < CarrierWave::Uploader::Base
  def aws_acl
    'private'
  end

  def aws_signer
    return if Rails.env.development? || Rails.env.test?

    lambda do |unsigned_url, _options|
      signer = Aws::S3::Presigner.new
      key = URI.parse(unsigned_url).path
      key.slice!(0)
      signer.presigned_url(:get_object, bucket: ENV['AWS_BUCKET'] || 'argu-logos', key: key)
    end
  end

  private

  def store_dir
    "export/#{model.id}"
  end
end
