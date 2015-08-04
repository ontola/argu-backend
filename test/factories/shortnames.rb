FactoryGirl.define do

  factory :shortname do
    sequence(:shortname) { |n| "fg_user#{n}" }
  end
end