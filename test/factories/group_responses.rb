FactoryGirl.define do

  factory :group_response do
    association :group
    association :motion
    association :profile, factory: :profile
    association :created_by, factory: :profile
  end
end
