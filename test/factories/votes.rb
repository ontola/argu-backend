FactoryGirl.define do

  factory :vote, traits: [:tenantable] do
    add_attribute :for, Vote.fors[:pro]
    association :voteable, factory: :motion, strategy: :create
    association :voter, factory: :profile, strategy: :create
  end
end
