FactoryGirl.define do

  factory :project do
    association :forum, strategy: :create
    association :creator, factory: :profile

    sequence(:title) { |n| "title#{n}" }
    content 'content'

  end
end
