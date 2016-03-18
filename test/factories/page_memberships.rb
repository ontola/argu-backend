FactoryGirl.define do
  factory :page_membership do
    transient do
      association :profile
      association :page
    end
    role PageMembership.roles[:member]

    factory :page_managership do
      role PageMembership.roles[:manager]
    end
  end
end
