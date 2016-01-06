FactoryGirl.define do

  factory :question do
    association :forum, strategy: :create
    association :creator, factory: :profile

    title 'title'
    content 'content'

    trait :with_motions do
      after(:create) do |question, evaluator|
        create_list :motion, 3,
                    question: question,
                    forum: question.forum
        create_list :motion, 3,
                    question: question,
                    forum: question.forum,
                    is_trashed: true
      end
    end
  end
end
