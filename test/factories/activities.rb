FactoryGirl.define do
  factory :activity, class: Activity do
    transient do
      tenant { passed_in?(:forum) ? forum : build(:forum) }
    end
    trackable { passed_in?(:trackable) ? trackable : create(:argument, forum: tenant) }

    association :owner, factory: :profile
    recipient { passed_in?(:recipient) ? recipient : tenant }
    key :create

    trait :t_question do
      trackable { create(:question, creator: owner, parent: tenant.edge) }
    end

    trait :t_motion do
      trackable { create(:motion, creator: owner, parent: tenant.edge) }
      recipient { passed_in?(:recipient) ? recipient : tenant }
    end

    trait :t_argument do
      trackable do
        passed_in?(:trackable) ? trackable : create(:argument,
                                                    parent: tenant.edge,
                                                    creator: owner)
      end
      recipient { passed_in?(:recipient) ? recipient : trackable.motion }
    end

    trait :t_comment do
      trackable { create(:comment, creator: owner) }
      recipient { passed_in?(:recipient) ? recipient : create(:argument, parent: tenant.edge) }
    end

    trait :t_vote do
      trackable { create(:vote, voter: owner) }
      recipient { passed_in?(:recipient) ? recipient : create(:motion, parent: tenant.edge) }
      parameters { passed_in?(:parameters) ? parameters : {for: trackable.for} }
    end

    trait :t_group_response do
      trackable { create(:group_response, creator: owner) }
    end

    factory :happening do
      key :happened
    end
  end
end
