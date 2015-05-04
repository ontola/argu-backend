FactoryGirl.define do

  factory :shortname do
    sequence(:shortname) { |n| "user#{n}" }
  end
end