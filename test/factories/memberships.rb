FactoryGirl.define do
  factory :membership do
    association :profile, strategy: :create
    association :forum
    role Membership.roles[:member]

    factory :managership do
      role Membership.roles[:manager]
    end
  end
end
