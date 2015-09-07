FactoryGirl.define do

  factory :motion do
    association :creator, factory: :profile

    sequence(:title) { |n| "title#{n}" }
    content 'content'
    is_trashed false
  end
end
