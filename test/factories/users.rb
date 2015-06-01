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
    first_name 'Thom'
    last_name 'van Kalkeren'

    factory :user_with_memberships do
      after(:create) do |user, evaluator|
        user.profile.memberships.create(forum: Forum.find_via_shortname('utrecht'))
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
