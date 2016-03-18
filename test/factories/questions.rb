FactoryGirl.define do
  factory :question do
    association :forum, strategy: :create
    association :creator, factory: :profile

    sequence(:title) { |n| "fg question title #{n}" }
    sequence(:content) { |n| "fg question content #{n}" }

    trait :with_motions do
      after(:create) do |question, evaluator|
        create_list :motion, 2,
                    question: question,
                    forum: question.forum
        create_list :motion, 2,
                    question: question,
                    forum: question.forum,
                    is_trashed: true
      end
    end
  end
end
