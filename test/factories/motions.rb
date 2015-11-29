FactoryGirl.define do

  factory :motion do
    association :forum, strategy: :create
    association :creator, factory: :profile
    transient do
      question nil
    end

    sequence(:title) { |n| "title#{n}" }
    content 'content'
    is_trashed false
    interactions_count 0

    after :create do |motion, evaluator|
      if evaluator.passed_in?(:question)
        create(:question_answer,
               motion: motion,
               question: evaluator.question)
      end
      create :activity,
             trackable: motion,
             forum: motion.forum,
             owner: motion.creator,
             key: 'motion.create'
    end

    trait :with_arguments do
      forum {
        passed_in?(:forum) ? forum : FactoryGirl.create(:forum)
      }
      after :create do |motion|
        create_list :argument, 5,
                    motion: motion,
                    forum: motion.forum
        create_list :argument, 5,
                    motion: motion,
                    forum: motion.forum,
                    pro: false,
                    is_trashed: true
        # Due to https://github.com/thoughtbot/factory_girl/issues/549
        motion.reload
        motion.update_counters
      end
    end

    trait :with_votes do
      after :create do |motion|
        create_list :vote, 2,
                    voteable: motion,
                    for: :pro
        create_list :vote, 2,
                    voteable: motion,
                    for: :neutral
        create_list :vote, 2,
                    voteable: motion,
                    for: :con
        # Due to https://github.com/thoughtbot/factory_girl/issues/549
        motion.reload
        motion.update_counters
      end
    end
  end
end
