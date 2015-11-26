FactoryGirl.define do

  factory :question do
    association :forum, strategy: :create
    association :creator, factory: :profile_direct_email

    title 'title'
    content 'content'

    trait :with_motions do
      after(:create) do |question, evaluator|
        create_list :motion, 3,
                    questions: [question]
        create_list :motion, 3,
                    questions: [question],
                    is_trashed: true
      end
    end
  end
end
