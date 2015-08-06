FactoryGirl.define do
  factory :forum do
    association :shortname, strategy: :build
    association :page, strategy: :create
    transient do
      motion_count 0
    end

    sequence(:name) { |n| "fg_forum#{n}" }

    factory :populated_forum do
      motion_count 20

      after(:create) do |forum, evaluator|
        create_list :motion, 10, forum: forum
        create_list :motion, 10, forum: forum, trashed: true
      end

      factory :closed_populated_forum, traits: [:closed]
      factory :hidden_populated_forum, traits: [:hidden]
    end


    trait :closed do
      visibility Forum.visibilities[:closed]
    end

    trait :hidden do
      visibility Forum.visibilities[:hidden]
    end
  end
end
