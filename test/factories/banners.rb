FactoryGirl.define do
  factory :banner do
    sequence(:title) { |n| "Banner title #{n}" }
    content 'Banner content'

    trait :published do
      published_at { 1.hours.ago }
    end

    trait :unpublished do
      published_at nil
    end

    trait :scheduled do
      published_at { 1.hour.from_now }
    end

    trait :ended do
      ends_at { 15.minutes.ago }
    end

    %i(guests users members everyone).each do |_audience|
       trait _audience do
         audience Banner.audiences[_audience]
       end
    end
  end
end
