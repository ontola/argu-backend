FactoryGirl.define do
  factory :comment do
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

    association :publisher, factory: :user
    sequence(:body) { |i| "fg comment body #{i}end" }
    is_trashed false

    after(:create) do |comment|
      comment.create_activity action: :create,
                              recipient: comment.commentable,
                              owner: comment.creator,
                              forum: comment.forum
    end
  end
end
