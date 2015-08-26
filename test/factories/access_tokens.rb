FactoryGirl.define do

  factory :access_token do
    #sequence(:access_token) { |n| "fg_access_token#{n}" }
    #association item
    association :profile, strategy: :build
  end
end
