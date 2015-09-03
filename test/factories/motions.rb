FactoryGirl.define do

  factory :motion do
    association :forum, strategy: :create
    association :creator, factory: :profile

    sequence(:title) { |n| "title#{n}" }
    content 'content'
    is_trashed false
  end
end
