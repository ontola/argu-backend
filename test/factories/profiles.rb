FactoryGirl.define do

  factory :profile do
    association :profileable, factory: :user, strategy: :build
    are_votes_public true
    is_public true

    factory :profile_with_memberships do
      after(:create) do |profile, evaluator|
        forum = evaluator.respond_to?(:forum) || FactoryGirl.create(:forum)
        profile.memberships.create(forum: forum)
      end
    end

    factory :profile_direct_email do
      association :profileable, factory: [:user, :follows_email], strategy: :build
    end
  end
end
