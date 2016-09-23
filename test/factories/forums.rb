# frozen_string_literal: true
FactoryGirl.define do
  factory :forum do
    association :shortname, strategy: :build
    association :page, strategy: :create
    visibility Forum.visibilities[:open]

    sequence(:name) { |n| "fg_forum#{n}end" }

    before(:create) do |forum|
      forum.build_edge
      forum.shortname.shortname = forum.name
    end

    # Cologne
    trait :closed do
      visibility Forum.visibilities[:closed]
    end

    # Helsinki
    trait :hidden do
      visibility Forum.visibilities[:hidden]
    end
  end
end
