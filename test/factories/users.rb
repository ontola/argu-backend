# frozen_string_literal: true

FactoryBot.define do
  factory :unconfirmed_user, class: User do
    association :profile, strategy: :build

    sequence :email do |n|
      "user#{n}@example.com"
    end
    encrypted_password { Devise::Encryptor.digest(User, 'password') }
    password { 'password' }
    password_confirmation { 'password' }
    language { 'en' }
    has_analytics { false }
    notifications_viewed_at { nil }
    show_feed { true }
    is_public { true }
    finished_intro { true }
    sequence(:display_name) { |n| "user_name_#{n}" }
    last_accepted { Time.current }

    trait :not_accepted_terms do
      last_accepted { nil }
    end

    trait :no_password do
      password { nil }
      password_confirmation { nil }
      encrypted_password { nil }
    end

    trait :staff do
      after(:create) do |user|
        gm = GroupMembership.new(
          group: Group.find(Group::STAFF_ID),
          member: user.profile,
          start_date: Time.current
        )
        gm.save!(validate: false)
      end
    end

    trait :viewed_notifications_hour_ago do
      notifications_viewed_at { 1.hour.ago }
    end

    trait :viewed_notifications_now do
      notifications_viewed_at { Time.current }
    end

    trait :follows_reactions_directly do
      reactions_email { User.reactions_emails[:direct_reactions_email] }
    end

    trait :follows_reactions_daily do
      reactions_email { User.reactions_emails[:daily_reactions_email] }
    end

    trait :follows_reactions_weekly do
      reactions_email { User.reactions_emails[:weekly_reactions_email] }
    end

    trait :follows_reactions_never do
      reactions_email { User.reactions_emails[:never_reactions_email] }
    end

    trait :follows_news_directly do
      news_email { User.news_emails[:direct_news_email] }
    end

    trait :follows_news_daily do
      news_email { User.news_emails[:daily_news_email] }
    end

    trait :follows_news_weekly do
      news_email { User.news_emails[:weekly_news_email] }
    end

    trait :follows_news_never do
      reactions_email { User.news_emails[:never_news_email] }
    end

    factory :user_with_votes do
      after(:create) do |user|
        motion = Motion.untrashed.first
        ActsAsTenant.with_tenant(motion.root) do
          CreateVote.new(
            motion.default_vote_event,
            attributes: {option: NS.argu[:yes]},
            options: {
              user_context: UserContext.new(
                profile: user.profile,
                user: user
              )
            }
          ).commit
          trashed = Motion.trashed.first
          CreateVote.new(
            trashed.default_vote_event,
            attributes: {option: NS.argu[:yes]},
            options: {
              user_context: UserContext.new(
                profile: user.profile,
                user: user
              )
            }
          ).commit
        end
      end
    end

    factory :user do
      after(:create) do |user|
        user.primary_email_record.update(confirmed_at: Time.current)
      end
      factory :two_fa_user do
        after(:create) do |user|
          OtpSecret.create!(owner: user, active: true)
        end
      end
    end
  end
end
