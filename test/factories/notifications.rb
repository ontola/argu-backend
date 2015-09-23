FactoryGirl.define do

  factory :notification do
    association :user
    association :activity
  end
end
