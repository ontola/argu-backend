FactoryGirl.define do

  factory :identity do
    transient do
      provider :facebook
    end
    trait(:facebook) { provider :facebook }

  end
end
