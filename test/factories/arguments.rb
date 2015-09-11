FactoryGirl.define do

  factory :argument, traits: [:tenantable] do
    association :motion, strategy: :create
    association :creator, factory: :profile
    pro true
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
