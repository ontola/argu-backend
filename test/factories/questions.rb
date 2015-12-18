FactoryGirl.define do

  factory :question do
    association :forum, strategy: :create
    association :creator, factory: :profile

    title 'title'
    content 'content'

    trait :with_motions do
      after(:create) do |question, evaluator|
        create_list :motion, 2,
                    questions: [question]
        create_list :motion, 2,
                    questions: [question],
                    is_trashed: true
      end
    end
  end
end
