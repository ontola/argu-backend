# frozen_string_literal: true

FactoryGirl.define do
  factory :linked_record do
    sequence(:iri) { |n| "https://iri.test/m/#{n}" }

    before :create do |record|
      record.edge = Edge.new(parent: record.source.edge, user_id: User::COMMUNITY_ID, is_published: true)
      record.page = record.source.page
    end

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
