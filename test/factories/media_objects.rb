# frozen_string_literal: true

FactoryBot.define do
  factory :media_object do
    used_as { :attachment }

    content do
      Rack::Test::UploadedFile.new(File.join(File.expand_path('test/fixtures/'), 'blank.pdf'), 'application/pdf')
    end

    factory :image_object do
      content do
        Rack::Test::UploadedFile.new(File.join(File.expand_path('test/fixtures/'), 'cover_photo.jpg'), 'image/jpeg')
      end
    end

    factory :profile_photo do
      used_as { :profile_photo }

      content do
        Rack::Test::UploadedFile.new(File.join(File.expand_path('test/fixtures/'), 'profile_photo.png'), 'image/png')
      end
    end
  end
end
