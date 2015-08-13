FactoryGirl.define do

  factory :vote do
    association :forum
    add_attribute :for, Vote.fors[:pro]
    association :voteable, factory: :motion, strategy: :create
    association :voter, factory: :profile, strategy: :create
  end
end
