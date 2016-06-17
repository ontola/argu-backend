FactoryGirl.define do
  factory :argument do
    forum { passed_in?(:forum) ? forum : create(:forum) }
    publisher { passed_in?(:publisher) ? publisher : create(:user) }
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end
    motion { passed_in?(:motion) ? motion : create(:motion, forum: forum) }
    pro true
    sequence(:title) { |i| "fg argument title #{i}end" }
    sequence(:content) { |i| "fg argument content #{i}end" }

    before :create do |argument|
      argument.motion.update forum: argument.forum
    end

    after :create do |argument|
      Argu::TestHelpers::FactoryGirlHelpers.create_activity_for(argument)
      argument.publisher.follow(argument.edge)
    end
  end
end
