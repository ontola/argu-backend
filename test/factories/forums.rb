FactoryGirl.define do
  factory :forum do
    association :shortname,  strategy: :build
    association :page, strategy: :create
    visibility Forum.visibilities[:open]
    transient do
      motion_count 0
    end

    sequence(:name) { |n| "fg_forum#{n}" }

    before(:create) do |forum, evaluator|
      forum.shortname.shortname = forum.name
    end

    # Holland (the default)
    factory :populated_forum, traits: [:with_follower] do
      motion_count 20

      after(:create) do |forum, evaluator|
        create_list :motion, 10, forum: forum
        create_list :motion, 10, forum: forum, is_trashed: true
        create :access_token, item: forum
        cap = Setting.get('user_cap').try(:to_i)
        Setting.set('user_cap', -1) unless cap.present?
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

    trait :with_follower do
      after(:create) do |forum, evaluator|
        FactoryGirl.create(:user, :confirmed).follow(forum)
      end
    end
  end
end
