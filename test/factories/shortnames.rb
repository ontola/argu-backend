FactoryGirl.define do

  factory :shortname do
    sequence(:shortname) { |n| "fg_shortname#{n}" }
    #association :owner
  end
end
