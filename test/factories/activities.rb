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
      trackable { FactoryGirl.create(:question, creator: owner) }
    end

    trait :t_motion do
      trackable { FactoryGirl.create(:motion, creator: owner) }
      recipient {
        passed_in?(:recipient) ?  recipient : tenant
      }
    end

    trait :t_argument do
      trackable {
        passed_in?(:trackable) ? trackable : FactoryGirl.create(:argument,
                                                                forum: tenant,
                                                                creator: owner)
      }
      recipient {
        passed_in?(:recipient) ?  recipient : trackable.motion
      }
    end

    trait :t_comment do
      trackable { FactoryGirl.create(:comment, profile: owner) }
      recipient {
        passed_in?(:recipient) ?  recipient : FactoryGirl.create(:argument, forum: tenant)
      }
    end

    trait :t_vote do
      trackable { FactoryGirl.create(:vote, voter: owner) }
      recipient {
        passed_in?(:recipient) ?  recipient : FactoryGirl.create(:motion, forum: tenant)
      }
    end

    trait :t_group_response do
      trackable { FactoryGirl.create(:group_response, profile: owner) }
    end
  end
end
