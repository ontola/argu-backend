# frozen_string_literal: true
FactoryGirl.define do
  factory :profile do
    are_votes_public true
    is_public true
    before(:create) do |profile|
      profile.update profileable: build(:user) if profile.profileable.blank?
    end

    after(:create) do |profile|
      profile.update name: 'page_profile' if profile.profileable.is_a?(Page)
    end

    factory :profile_with_memberships do
      after(:create) do |profile, evaluator|
        forum = evaluator.respond_to?(:forum) || create(:forum)
        profile.memberships.create(forum: forum)
      end
    end

    factory :profile_direct_email do
      association :profileable, factory: [:user, :follows_reactions_directly], strategy: :build
    end
  end
end
