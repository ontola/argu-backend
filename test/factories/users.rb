# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    association :profile, strategy: :build
    association :shortname, strategy: :build

    sequence :email do |n|
      "user#{n}@example.com"
    end
    encrypted_password { Devise::Encryptor.digest(User, 'password') }
    password 'password'
    password_confirmation 'password'
    finished_intro true
    language 'en'
    has_analytics false
    notifications_viewed_at nil
    sequence(:first_name) { |n| "first_name_#{n}" }
    sequence(:last_name) { |n| "last_name_#{n}" }

    after(:create) do |user|
      user.primary_email_record.update(confirmed_at: DateTime.current)
    end

    trait :staff do
      after(:create) do |user|
        user.profile.add_role :staff
      end
    end

    trait :unconfirmed do
      after(:create) do |user|
        user.primary_email_record.update(
          confirmed_at: nil,
          confirmation_sent_at: 1.year.ago,
          unconfirmed_email: user.email
        )
      end
    end

    trait :viewed_notifications_hour_ago do
      notifications_viewed_at 1.hour.ago
    end

    trait :viewed_notifications_now do
      notifications_viewed_at DateTime.current
    end

    trait :follows_reactions_directly do
      reactions_email User.reactions_emails[:direct_reactions_email]
    end

    trait :follows_reactions_daily do
      reactions_email User.reactions_emails[:daily_reactions_email]
    end

    trait :follows_reactions_weekly do
      reactions_email User.reactions_emails[:weekly_reactions_email]
    end

    trait :follows_reactions_never do
      reactions_email User.reactions_emails[:never_reactions_email]
    end

    trait :follows_news_directly do
      news_email User.news_emails[:direct_news_email]
    end

    trait :follows_news_daily do
      news_email User.news_emails[:daily_news_email]
    end

    trait :follows_news_weekly do
      news_email User.news_emails[:weekly_news_email]
    end

    trait :follows_news_never do
      reactions_email User.news_emails[:never_news_email]
    end

    factory :user_with_votes do
      after(:create) do |user|
        motion = Motion.untrashed.first
        CreateVote.new(
          motion.default_vote_event.edge,
          attributes: {for: :pro},
          options: {
            creator: user.profile,
            publisher: user
          }
        ).commit
        trashed = Motion.trashed.first
        CreateVote.new(
          trashed.default_vote_event.edge,
          attributes: {for: :pro},
          options: {
            creator: user.profile,
            publisher: user
          }
        ).commit
      end
    end
  end
end
