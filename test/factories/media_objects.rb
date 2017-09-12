# frozen_string_literal: true

FactoryGirl.define do
  factory :media_object, traits: [:set_publisher] do
    used_as :attachment
    association :forum

    content Rack::Test::UploadedFile.new(File.join(File.expand_path('test/fixtures/'), 'blank.pdf'), 'application/pdf')

    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end

    factory :image_object do
      content Rack::Test::UploadedFile
                .new(File.join(File.expand_path('test/fixtures/'), 'cover_photo.jpg'), 'image/jpeg')
    end
  end
end
