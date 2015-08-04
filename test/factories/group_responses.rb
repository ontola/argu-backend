FactoryGirl.define do

  factory :group_response do
    association :group
    forum Forum.find_via_shortname_nil('utrecht')
    association :motion
    association :profile, factory: :profile
    association :created_by, factory: :profile
  end
end
