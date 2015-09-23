FactoryGirl.define do

  factory :group_response do
    association :group
    association :forum, strategy: :build
    association :motion
    association :profile, factory: :profile
    association :publisher, factory: :user
  end
end
