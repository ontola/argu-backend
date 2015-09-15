FactoryGirl.define do

  factory :motion, traits: [:tenantable] do
    association :creator, factory: :profile

    sequence(:title) { |n| "title#{n}" }
    content 'content'
    is_trashed false

    trait :with_arguments do
      after :create do |motion|
        create_list :argument, 10,
                    motion: motion
        create_list :argument, 10,
                    motion: motion,
                    pro: false,
                    is_trashed: true
      end
    end
  end
end
