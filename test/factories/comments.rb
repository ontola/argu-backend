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
    creator { passed_in?(:creator) ? creator : create(:profile) }
    association :publisher, factory: [:user, :follows_reactions_directly]
    sequence(:body) { |i| "fg comment body #{i}end" }
    is_trashed false

    after(:create) do |comment|
      comment.create_activity action: :create,
                              recipient: comment.parent_model,
                              owner: comment.creator,
                              forum: comment.forum
      comment.publisher.follow(comment.edge)
    end
  end
end
