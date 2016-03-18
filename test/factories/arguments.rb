FactoryGirl.define do

  factory :argument do
    association :forum, strategy: :build
    association :creator, factory: :profile
    motion {
      passed_in?(:motion) ? motion : create(:motion, forum: forum)
    }
    pro true
    sequence(:title) { |i| "fg argument title #{i}" }
    sequence(:content) { |i| "fg argument content #{i}" }

    before :create do |argument, evaluator|
      argument.motion.update forum: argument.forum
    end
  end
end
