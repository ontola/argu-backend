FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    association :shortname, strategy: :build

    email
    encrypted_password { Devise.bcrypt(User, 'password') }
    password 'password'
    password_confirmation 'password'
    finished_intro true
    has_analytics false
    first_name { |n| 'first_name#{n}' }
    last_name { |n| 'last_name#{n}' }

    trait :forum_manager do
      after(:create) do |user, evaluator|
        create(:profile_with_memberships)
      end
    end

    trait :staff do
      staff true
    end

    factory :user_with_notification do
      after(:create) do |user, evaluator|
        user.profile.notifications.create
      end
    end


    factory :user_with_memberships do
      after(:create) do |user, evaluator|
        user.profile.memberships.create(forum: FactoryGirl.create(:forum))
      end

      factory :user_with_votes do
        after(:create) do |user, evaluator|
          motion = Motion.find_by(is_trashed: false)
          user.profile.votes.create(voteable: motion, forum: motion.forum, for: :pro)
          trashed = Motion.find_by(is_trashed: true)
          user.profile.votes.create(voteable: trashed, forum: trashed.forum, for: :pro)
        end
      end
    end
  end
end
