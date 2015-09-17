FactoryGirl.define do
  factory :forum do
    association :shortname, strategy: :build
    association :page, strategy: :create
    visibility Forum.visibilities[:open]
    transient do
      #visible_with_a_link false
      motion_count 0
    end

    sequence(:name) { |n| "fg_forum#{n}" }

    before(:create) do |forum, evaluator|
      forum.shortname.shortname = forum.name
    end

    after(:create) do |forum, evaluator|
      Apartment::Tenant.create(forum.shortname.shortname)
    end

    # Holland (the default)
    factory :populated_forum do
      motion_count 20

      after(:create) do |forum, evaluator|
        Apartment::Tenant.switch forum.to_param do
          create_list :motion, 10, tenant: forum.to_param
          create_list :motion, 10, tenant: forum.to_param, is_trashed: true
          create :access_token, item: forum
          cap = Setting.get('user_cap').try(:to_i)
          Setting.set('user_cap', -1) unless cap.present?
        end
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

    trait :with_access_token do
      after(:create) do |forum, evaluator|
        forum.access_tokens.create(creator: forum.page.profile)
      end
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
