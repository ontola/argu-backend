FactoryGirl.define do

  factory :votes do
    add_attribute :for, Vote.fors[:pro]
  end
end