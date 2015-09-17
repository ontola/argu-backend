FactoryGirl.define do

  factory :argument, traits: [:tenantable] do
    association :creator, factory: :profile
    association :motion, strategy: :create
    sequence :pro do |n|
      n % 2 == 0 ? true : false
    end
    title 'title'
    content 'argument'

    trait :with_comments do
      after(:create) do |argument, evaluator|
        create_list :comment, 10, commentable: argument
        create_list :comment, 10, commentable: argument, is_trashed: true
      end
    end
  end
end
