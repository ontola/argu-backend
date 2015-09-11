FactoryGirl.define do

  factory :comment, traits: [:tenantable] do
    association :commentable, factory: :argument
    association :creator, factory: :profile
    body 'comment'
    is_trashed false

    after(:create) do |comment, evaluator|
      comment.create_activity action: :create,
                              recipient: comment.commentable,
                              owner: comment.creator
      comment.refresh_counter_cache
    end
  end
end
