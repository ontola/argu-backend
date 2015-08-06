FactoryGirl.define do

  factory :profile do
    transient do
      association :profileable, factory: :user, strategy: :build
      is_public true
    end

    factory :profile_with_memberships do
      after(:create) do |profile, evaluator|
        profile.memberships.create(forum: evaluator.forum)
      end
    end
  end
end
