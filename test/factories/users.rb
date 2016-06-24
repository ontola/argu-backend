FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    association :profile, strategy: :build
    association :shortname, strategy: :build

    email
    encrypted_password { Devise::Encryptor.digest(User, 'password') }
    password 'password'
    password_confirmation 'password'
    finished_intro true
    language 'en'
    has_analytics false
    notifications_viewed_at nil
    sequence(:first_name) { |n| "first_name_#{n}" }
    sequence(:last_name) { |n| "last_name_#{n}" }

    trait :staff do
      after(:create) do |user|
        user.profile.add_role :staff
      end
    end

    trait :confirmed do
      confirmed_at Time.current
    end

    trait :viewed_notifications_hour_ago do
      notifications_viewed_at 1.hour.ago
    end

    trait :viewed_notifications_now do
      notifications_viewed_at DateTime.current
    end

    trait :follows_reactions_directly do
      confirmed_at Time.current
      reactions_email User.reactions_emails[:direct_reactions_email]
    end

    trait :follows_reactions_weekly do
      confirmed_at Time.current
      reactions_email User.reactions_emails[:weekly_reactions_email]
    end

    trait :follows_reactions_never do
      confirmed_at Time.current
      reactions_email User.reactions_emails[:never_reactions_email]
    end

    trait :follows_news_directly do
      confirmed_at Time.current
      news_email User.news_emails[:direct_news_email]
    end

    trait :follows_news_weekly do
      confirmed_at Time.current
      news_email User.news_emails[:weekly_news_email]
    end

    trait :follows_news_never do
      confirmed_at Time.current
      reactions_email User.news_emails[:never_news_email]
    end

    trait :forum_manager do
      after(:create) do
        create(:profile_with_memberships)
      end
    end

    trait :with_notifications do
      after(:create) do |user|
        f = create :forum
        %i(question motion argument comment vote group_response).each do |type|
          create :notification,
                 user: user,
                 activity: create(:activity,
                                  "t_#{type}".to_sym,
                                  forum: f)
        end
      end
    end

    factory :user_with_memberships do
      after(:create) do |user|
        user.profile.memberships.create(forum: create(:forum))
      end

      factory :user_with_votes do
        after(:create) do |user|
          motion = Motion.find_by(is_trashed: false)
          user.profile.votes.create(voteable: motion,
                                    forum: motion.forum,
                                    publisher: user,
                                    for: :pro)
          trashed = Motion.find_by(is_trashed: true)
          user.profile.votes.create(voteable: trashed,
                                    forum: trashed.forum,
                                    publisher: user,
                                    for: :pro)
        end
      end
    end
  end
end
