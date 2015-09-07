FactoryGirl.define do

  factory :activity do
    association :owner, factory: :profile
    association :trackable, factory: :question
    association :recipient, factory: :forum
    key :create

    trait :t_question do
      association :trackable, factory: :question
    end

    trait :t_motion do
      association :trackable, factory: :motion
    end

    trait :t_argument do
      association :trackable, factory: :argument
    end

    trait :t_comment do
      association :trackable, factory: :comment
    end

    trait :t_vote do
      association :trackable, factory: :vote
    end

    trait :t_group_response do
      association :trackable, factory: :group_response
    end
  end
end
