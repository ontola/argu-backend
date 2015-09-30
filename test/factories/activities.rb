FactoryGirl.define do

  factory :activity do
    transient do
      tenant {
        passed_in?(:forum) ? forum : FactoryGirl.build(:forum)
      }
    end

    #association :forum
    association :owner, factory: :profile
    #association :trackable, factory: :question
    recipient {
      passed_in?(:trackable) ?  trackable : tenant
    }
    key :create

    trait :t_question do
      association :trackable, factory: :question
    end

    trait :t_motion do
      association :trackable, factory: :motion
    end

    trait :t_argument do
      trackable {
        passed_in?(:trackable) ? trackable : FactoryGirl.create(:argument, forum: tenant)
      }
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
