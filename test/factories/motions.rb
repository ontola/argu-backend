FactoryGirl.define do

  factory :motion do
    association :forum, strategy: :create
    association :creator, factory: :profile
    #association :question, factory: :question

    sequence(:title) { |n| "title#{n}" }
    content 'content'
    is_trashed false

    after :create do |motion, evaluator|
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
      end
    end

    trait :with_group_responses do
      after :create do |motion|
        g = create(:group,
                   visibility: :discussion,
                   forum: motion.forum)
        create_list :group_response, 2,
                    group: g
        create(:group,
               visibility: :hidden,
               forum: motion.forum)
        create(:group,
               visibility: :visible,
               forum: motion.forum)
      end
    end
  end
end
