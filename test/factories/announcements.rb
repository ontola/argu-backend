FactoryGirl.define do

  factory :announcement do

    sequence(:title) { |n| "Announcement title #{n}" }
    sequence(:content) { |n| "Announcement content #{n}" }

    trait :published do
      published_at { 1.hour.ago }
    end

    trait :unpublished do
      published_at nil
    end

    trait :scheduled do
      published_at { 1.hour.from_now }
    end

    %i(guests users members everyone).each do |_audience|
       trait _audience do
         audience Announcement.audiences[_audience]
       end
    end

  end
end
