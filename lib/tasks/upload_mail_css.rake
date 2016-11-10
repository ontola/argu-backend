# frozen_string_literal: true
namespace :upload do
  desc 'Upload mail.css to amazon'
  task css: :environment do
    Aws::S3::Object.new(
      bucket_name: 'argu-ci-artifacts',
      key: 'mail.css',
      client: Aws::S3::Client.new(access_key_id: ENV['AWS_ID'], secret_access_key: ENV['AWS_KEY'])
    ).upload_file(Dir['public/assets/mail-*.css'].first)
  end
end
