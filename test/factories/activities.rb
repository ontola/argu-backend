# frozen_string_literal: true

FactoryBot.define do
  factory :activity, class: Activity do
    transient do
      tenant { passed_in?(:forum) ? forum : build(:forum) }
    end
    trackable { passed_in?(:trackable) ? trackable : create(:pro_argument, parent: tenant) }

    association :owner, factory: :profile
    recipient { passed_in?(:recipient) ? recipient : tenant }
    key { :create }

    trait :t_question do
      trackable { create(:question, creator: owner, parent: tenant) }
    end

    trait :t_motion do
      trackable { create(:motion, creator: owner, parent: tenant) }
      recipient { passed_in?(:recipient) ? recipient : tenant }
    end

    trait :t_argument do
      trackable do
        passed_in?(:trackable) ? trackable : create(:pro_argument, parent: tenant, creator: owner)
      end
      recipient { passed_in?(:recipient) ? recipient : trackable.motion }
    end

    trait :t_comment do
      trackable { create(:comment, creator: owner) }
      recipient { passed_in?(:recipient) ? recipient : create(:pro_argument, parent: tenant) }
    end

    trait :t_vote do
      trackable { create(:vote, creator: owner) }
      recipient { passed_in?(:recipient) ? recipient : create(:motion, parent: tenant) }
      parameters { passed_in?(:parameters) ? parameters : {option: trackable.option} }
    end
  end
end
