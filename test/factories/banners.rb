# frozen_string_literal: true

FactoryGirl.define do
  factory :banner do
    association :forum
    sequence(:title) { |n| "Banner title #{n}" }
    sequence(:content) { |n| "Banner content #{n}" }
    publisher { passed_in?(:publisher) ? publisher : create(:user) }

    trait :published do
      published_at { 1.hour.ago }
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

    trait :without_ending do
      ends_at nil
    end

    trait :not_yet_ended do
      ends_at { 15.minutes.from_now }
    end

    %i(guests users members everyone).each do |aud|
      trait aud do
        audience Banner.audiences[aud]
      end
    end
  end
end
