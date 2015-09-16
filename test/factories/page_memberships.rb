FactoryGirl.define do

  factory :page_membership do
    association :profile
    association :page
    role PageMembership.roles[:member]

    trait :managership do
      role PageMembership.roles[:manager]
    end
  end
end
