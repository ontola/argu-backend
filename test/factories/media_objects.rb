# frozen_string_literal: true
FactoryGirl.define do
  factory :media_object, traits: [:set_publisher] do
    filename { "mediaobject-#{id}.pdf" }
    content_type 'application/pdf'
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end
    factory :image_object do
      filename { "imageobject-#{id}.png" }
      content_type 'image/png'
    end
  end
end
