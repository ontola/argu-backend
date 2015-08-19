FactoryGirl.define do

  factory :profile do
    association :profileable, factory: :user, strategy: :build
    are_votes_public true
    is_public true

    factory :profile_with_memberships do
      after(:create) do |profile, evaluator|
        profile.memberships.create(forum: evaluator.forum)
      end
    end
  end
end
