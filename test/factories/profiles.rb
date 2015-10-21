FactoryGirl.define do
  factory :profile do
    are_votes_public true
    is_public true
    after(:create) do |profile|
      profile.update profileable: build(:user) if profile.profileable.blank?
    end

    after(:create) do |profile, evaluator|
      if (profile.profileable.is_a?(Page))
        profile.update name: 'page_profile'
      end
    end

    factory :profile_with_memberships do
      after(:create) do |profile, evaluator|
        forum = evaluator.respond_to?(:forum) || create(:forum)
        profile.memberships.create(forum: forum)
      end
    end

    factory :profile_direct_email do
      after(:create) do |profile|
        profile.update profileable: build(:user, :follows_email)
      end
    end
  end
end
