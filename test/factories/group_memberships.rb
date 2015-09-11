FactoryGirl.define do

  factory :group_membership, traits: [:tenantable] do
    association :group
    association :member, factory: :profile

  end
end
