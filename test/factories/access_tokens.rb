FactoryGirl.define do

  factory :access_token do
    sequence(:access_token) { |n| "fg_access_token#{n}" }
    transient do
      #association item
      association :profile, strategy: :build
    end
  end
end
