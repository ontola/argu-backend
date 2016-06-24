FactoryGirl.define do
  factory :motion do
    forum { passed_in?(:forum) ? forum : create(:forum) }
    publisher { passed_in?(:publisher) ? publisher : create(:user) }
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end

    sequence(:title) { |n| "fg motion title #{n}end" }
    sequence(:content) { |i| "fg motion content #{i}end" }
    is_trashed false

    trait :with_arguments do
      forum do
        passed_in?(:forum) ? forum : create(:forum)
      end
      after :create do |motion|
        create_list :argument, 3,
                    motion: motion,
                    forum: motion.forum
        create_list :argument, 3,
                    motion: motion,
                    forum: motion.forum,
                    pro: false,
                    is_trashed: true
      end
    end
  end
end
