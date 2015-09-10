FactoryGirl.define do

  factory :argument do
    transient do
      tenant nil
    end

    association :motion, strategy: :create
    association :creator, factory: :profile
    pro true
    title 'title'
    content 'argument'

    before(:create) do |argument, evaluator|
      if evaluator.tenant.present?
        Apartment::Tenant.switch! evaluator.tenant
      end
    end

    trait :with_comments do
      after(:create) do |argument, evaluator|
        create_list :comment, 10, commentable: argument
        create_list :comment, 10, commentable: argument, is_trashed: true
      end
    end
  end
end
