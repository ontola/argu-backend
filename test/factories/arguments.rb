FactoryGirl.define do

  factory :argument do
    association :forum, strategy: :build
    association :creator, factory: :profile
    motion {
      passed_in?(:motion) ? motion : FactoryGirl.create(:motion, forum: forum)
    }
    pro true
    title 'title'
    content 'argument'

    before :create do |argument, evaluator|
      argument.motion.update forum: argument.forum
      argument.votes.build(voter: argument.creator,
                           for: Vote.fors[:pro],
                           forum: argument.forum)
    end
  end
end
