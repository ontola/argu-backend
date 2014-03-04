# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :email do |n|
    "some_#{n}@example.com"
  end

  sequence :username do |n|
    "user#{n}"
  end

  factory :user, aliases: [:creator] do
    username
    email
    password 'foobar'
    password_confirmation 'foobar'

    factory :admin do
      after(:create) { |user| user.add_role :admin }
    end

    factory :coder do
      after(:create) { |user| user.add_role :coder }
    end
  end
end
