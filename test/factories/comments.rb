FactoryGirl.define do

  factory :comment do
    transient do
      forum { FactoryGirl.build(:forum) }
    end

    commentable {
      passed_in?(:commentable) ? commentable : FactoryGirl.create(:argument, forum: forum)
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
