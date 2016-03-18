FactoryGirl.define do
  factory :activity do
    transient do
      tenant {
        passed_in?(:forum) ? forum : build(:forum)
      }
    end
    trackable {
      passed_in?(:trackable) ? trackable : create(:argument, forum: tenant)
    }

    #association :forum
    association :owner, factory: :profile
    #association :trackable, factory: :question
    recipient {
      passed_in?(:recipient) ?  recipient : tenant
    }
    key :create

    trait :t_question do
      trackable { create(:question, creator: owner) }
    end

    trait :t_motion do
      trackable { create(:motion, creator: owner) }
      recipient {
        passed_in?(:recipient) ?  recipient : tenant
      }
    end

    trait :t_argument do
      trackable {
        passed_in?(:trackable) ? trackable : create(:argument,
                                                    forum: tenant,
                                                    creator: owner)
      }
      recipient {
        passed_in?(:recipient) ?  recipient : trackable.motion
      }
    end

    trait :t_comment do
      trackable { create(:comment, creator: owner) }
      recipient {
        passed_in?(:recipient) ?  recipient : create(:argument, forum: tenant)
      }
    end

    trait :t_vote do
      trackable { create(:vote, voter: owner) }
      recipient {
        passed_in?(:recipient) ?  recipient : create(:motion, forum: tenant)
      }
      parameters {
        passed_in?(:parameters) ? parameters : {for: trackable.for}
      }
    end

    trait :t_group_response do
      trackable { create(:group_response, creator: owner) }
    end
  end
end
