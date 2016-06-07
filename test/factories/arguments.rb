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

    after :create do |argument|
      argument.create_activity action: :create,
                               recipient: argument.parent_model,
                               owner: argument.creator,
                               forum: argument.forum
      argument.publisher.follow(argument.edge)
    end
  end
end
