FactoryGirl.define do

  factory :comment do
    commentable {
      passed_in?(:commentable) ? commentable : FactoryGirl.create(:argument, forum: forum)
    }
    forum {
      if passed_in?(:forum)
        forum
      elsif passed_in?(:commentable)
        commentable.forum
      else
        FactoryGirl.create(:forum)
      end
    }
    association :profile
    association :publisher, factory: :user
    body 'comment'
    is_trashed false

    after(:create) do |comment, evaluator|
      comment.create_activity action: :create,
                              recipient: comment.commentable,
                              owner: comment.profile,
                              forum: comment.forum
    end
  end
end
