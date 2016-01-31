FactoryGirl.define do

  factory :phase do
    association :forum, strategy: :create
    association :project, strategy: :create
    association :creator, factory: :profile

    sequence(:name) { |n| "title#{n}" }
    description 'content'

  end
end
