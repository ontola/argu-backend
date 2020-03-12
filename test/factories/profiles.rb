# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    before(:create) do |profile|
      profile.profileable ||= build(:user, profile: profile)
    end

    after(:create) do |profile|
      profile.update name: 'page_profile' if profile.profileable.is_a?(Page)
    end

    factory :profile_direct_email do
      association :profileable, factory: %i[user follows_reactions_directly], strategy: :build
    end
  end
end
