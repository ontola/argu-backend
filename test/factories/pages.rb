FactoryGirl.define do
  factory :page do
    association :profile, strategy: :build
    association :shortname, strategy: :build
    association :owner, factory: :profile, strategy: :create
    last_accepted Time.now
  end
end
