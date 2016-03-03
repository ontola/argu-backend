FactoryGirl.define do

  factory :argument do
    association :forum, strategy: :build
    association :creator, factory: :profile
    motion {
      passed_in?(:motion) ? motion : FactoryGirl.create(:motion, forum: forum)
    }
    pro true
    sequence(:title) { |i| "fg_title_#{i}" }
    sequence(:content) { |i| "fg_content_#{i}" }

    before :create do |argument, evaluator|
      argument.motion.update forum: argument.forum
    end
  end
end
