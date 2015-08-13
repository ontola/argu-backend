FactoryGirl.define do

  factory :notification do
    association :profile
    association :activity
  end
end
