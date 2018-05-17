# frozen_string_literal: true

FactoryGirl.define do
  factory :media_object do
    used_as :attachment

    content Rack::Test::UploadedFile.new(File.join(File.expand_path('test/fixtures/'), 'blank.pdf'), 'application/pdf')

    factory :image_object do
      content Rack::Test::UploadedFile
                .new(File.join(File.expand_path('test/fixtures/'), 'cover_photo.jpg'), 'image/jpeg')
    end
  end
end
