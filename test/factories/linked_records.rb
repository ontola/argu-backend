# frozen_string_literal: true

FactoryGirl.define do
  factory :linked_record do
    trait :with_votes do
      after(:create) do |resource|
        Argu::TestHelpers::TraitListener.new(resource).with_votes
      end
    end

    trait :with_arguments do
      after(:create) do |resource|
        Argu::TestHelpers::TraitListener.new(resource).with_arguments
      end
    end
  end
end
