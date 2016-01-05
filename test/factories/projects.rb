FactoryGirl.define do

  factory :project do
    association :forum, strategy: :create
    association :creator, factory: :profile

    title 'title'
    content 'content'

    trait :with_content do
      after(:create) do |project, evaluator|

      end
    end
  end
end
