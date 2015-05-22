FactoryGirl.define do

  factory :identity do

    trait(:facebook) { provider :facebook }

  end
end
