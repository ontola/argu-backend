FactoryGirl.define do
  factory :forum do
    association :shortname, strategy: :build
    association :page, strategy: :create
    transient do
      #visible_with_a_link false
      motion_count 0
    end

    sequence(:name) { |n| "fg_forum#{n}" }

    # Holland (the default)
    factory :populated_forum do
      motion_count 20

      after(:create) do |forum, evaluator|
        create_list :motion, 10, forum: forum
        create_list :motion, 10, forum: forum, is_trashed: true
        create :access_token, item: forum
      end

      factory :populated_forum_vwal, traits: [:vwal]
      factory :closed_populated_forum, traits: [:closed]
      factory :closed_populated_forum_vwal, traits: [:closed, :vwal]
      factory :hidden_populated_forum, traits: [:hidden]
      factory :hidden_populated_forum_vwal, traits: [:hidden, :vwal]
    end

    # Venice
    trait :vwal do
      visible_with_a_link true
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
