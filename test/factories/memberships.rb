FactoryGirl.define do

  factory :membership do
    association :profile
    association :forum
    role Membership.roles[:member]

    trait :managership do
      role Membership.roles[:manager]
    end
  end
end
