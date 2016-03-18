FactoryGirl.define do
  factory :argument do
    association :forum, strategy: :build
    creator {
      passed_in?(:creator) ? creator : create(:profile)
    }
    publisher {
      passed_in?(:publisher) ? publisher : create(:user)
    }
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
