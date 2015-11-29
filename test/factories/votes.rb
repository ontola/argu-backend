FactoryGirl.define do

  factory :vote do
    association :forum
    association :voteable, factory: :motion, strategy: :create
    association :voter, factory: :profile, strategy: :create
    add_attribute :for, Vote.fors[:pro]
  end
end
