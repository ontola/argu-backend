FactoryGirl.define do
  factory :project do
    association :forum, strategy: :create
    association :creator, factory: :profile
    start_date Time.current
    sequence(:title) { |n| "title#{n}" }
    content 'content'

    factory :published_project do
      published_at Time.current
    end
  end
end
