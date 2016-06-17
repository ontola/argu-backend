FactoryGirl.define do
  factory :question do
    association :forum, strategy: :create
    association :publisher, factory: [:user, :follows_reactions_directly]
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end
    sequence(:title) { |n| "fg question title #{n}end" }
    sequence(:content) { |n| "fg question content #{n}end" }

    after :create do |question|
      Argu::TestHelpers::FactoryGirlHelpers.create_activity_for(question)
      question.publisher.follow(question.edge)
    end

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
