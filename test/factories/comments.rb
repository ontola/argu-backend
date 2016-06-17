FactoryGirl.define do
  factory :comment, traits: [:set_publisher] do
    commentable { passed_in?(:commentable) ? commentable : create(:argument, forum: forum) }
    forum do
      if passed_in?(:forum)
        forum
      elsif passed_in?(:commentable)
        commentable.forum
      else
        create(:forum)
      end
    end
    association :publisher, factory: [:user, :follows_reactions_directly]
    creator do
      if passed_in?(:creator)
        creator
      else
        publisher.present? ? publisher.profile : create(:profile)
      end
    end
    sequence(:body) { |i| "fg comment body #{i}end" }
    is_trashed false

    after(:create) do |comment|
      Argu::TestHelpers::FactoryGirlHelpers.create_activity_for(comment)
      comment.publisher.follow(comment.edge)
    end
  end
end
