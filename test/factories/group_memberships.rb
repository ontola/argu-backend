FactoryGirl.define do
  factory :group_membership do
    association :group
    association :member, factory: :profile
  end
end
