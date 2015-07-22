FactoryGirl.define do

  factory :profile do
    association :profileable, factory: :user, strategy: :build

    is_public true
  end
end
