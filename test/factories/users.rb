FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    association :profile, strategy: :build
    association :shortname, strategy: :build

    confirmed_at Time.current
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

    trait :unconfirmed do
      confirmed_at nil
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

    trait :follows_reactions_weekly do
      reactions_email User.reactions_emails[:weekly_reactions_email]
    end

    trait :follows_reactions_never do
      reactions_email User.reactions_emails[:never_reactions_email]
    end

    trait :follows_news_directly do
      news_email User.news_emails[:direct_news_email]
    end

    trait :follows_news_weekly do
      news_email User.news_emails[:weekly_news_email]
    end

    trait :follows_news_never do
      reactions_email User.news_emails[:never_news_email]
    end

    trait :forum_manager do
      after(:create) do
        create(:profile_with_memberships)
      end
    end

    factory :user_with_memberships do
      after(:create) do |user|
        page = create(:page)
        service = CreateForum.new(
          page.edge,
          attributes: {page: page},
          options: {
            creator: page.owner,
            publisher: page.owner.profileable})
        service.commit
        forum = service.resource
        user.profile.memberships.create(group: forum.members_group)
      end

      factory :user_with_votes do
        after(:create) do |user|
          motion = Motion.find_by(is_trashed: false)
          CreateVote.new(
            motion.edge,
            attributes: {for: :pro},
            options: {
              creator: user.profile,
              publisher: user}).commit
          trashed = Motion.find_by(is_trashed: true)
          CreateVote.new(
            trashed.edge,
            attributes: {for: :pro},
            options: {
              creator: user.profile,
              publisher: user}).commit
        end
      end
    end
  end
end
