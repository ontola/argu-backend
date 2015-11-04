FactoryGirl.define do

  factory :activity do
    transient do
      tenant {
        passed_in?(:forum) ? forum : FactoryGirl.build(:forum)
      }
    end
    trackable {
      passed_in?(:trackable) ? trackable : FactoryGirl.create(:argument, forum: tenant)
    }

    #association :forum
    association :owner, factory: :profile
    #association :trackable, factory: :question
    recipient {
      passed_in?(:recipient) ?  recipient : tenant
    }
    key :create

    trait :t_question do
      association :trackable, factory: :question
    end

    trait :t_motion do
      association :trackable, factory: :motion
      recipient {
        passed_in?(:recipient) ?  recipient : tenant
      }
    end

    trait :t_argument do
      trackable {
        passed_in?(:trackable) ? trackable : FactoryGirl.create(:argument, forum: tenant)
      }
      recipient {
        passed_in?(:recipient) ?  recipient : trackable.motion
      }
    end

    trait :t_comment do
      association :trackable, factory: :comment
      recipient {
        passed_in?(:recipient) ?  recipient : FactoryGirl.create(:argument, forum: tenant)
      }
    end

    trait :t_vote do
      association :trackable, factory: :vote
      recipient {
        passed_in?(:recipient) ?  recipient : FactoryGirl.create(:motion, forum: tenant)
      }
    end

    trait :t_group_response do
      association :trackable, factory: :group_response
    end
  end
end
