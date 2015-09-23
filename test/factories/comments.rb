FactoryGirl.define do

  factory :comment do
    association :commentable, factory: :argument
    association :profile
    association :publisher, factory: :user
    body 'comment'
    is_trashed false

    after(:create) do |comment, evaluator|
      comment.create_activity action: :create,
                              recipient: comment.commentable,
                              owner: comment.profile,
                              forum_id: comment.forum.id
    end
  end
end
