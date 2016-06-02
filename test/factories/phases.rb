FactoryGirl.define do
  factory :phase, traits: [:set_publisher] do
    association :forum, strategy: :create
    association :project, strategy: :create
    association :creator, factory: :profile

    sequence(:name) { |n| "title#{n}" }
    description 'content'
  end
end
