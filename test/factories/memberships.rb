FactoryGirl.define do

  factory :membership do
    transient do
      association :profile
      association :forum
    end
    role Membership.roles[:member]

    factory :managership do
      role Membership.roles[:manager]
    end
  end
end
