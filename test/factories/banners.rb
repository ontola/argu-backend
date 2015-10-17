FactoryGirl.define do

  factory :banner do

    trait :published do
      publish_at { 1.hour.ago }
    end

    trait :unpublished do
      publish_at nil
    end

    trait :scheduled do
      publish_at { 1.hour.from_now }
    end

    %i(guests users members everyone).each do |_audience|
       trait _audience do
         audience Banner.audiences[_audience]
       end
    end

  end
end
