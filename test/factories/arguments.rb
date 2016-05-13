FactoryGirl.define do
  factory :argument do
    forum { passed_in?(:forum) ? forum : create(:forum) }
    creator { passed_in?(:creator) ? creator : create(:profile) }
    publisher { passed_in?(:publisher) ? publisher : create(:user) }
    motion { passed_in?(:motion) ? motion : create(:motion, forum: forum) }
    pro true
    sequence(:title) { |i| "fg argument title #{i}end" }
    sequence(:content) { |i| "fg argument content #{i}end" }

    before :create do |argument|
      argument.motion.update forum: argument.forum
    end
  end
end
