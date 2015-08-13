FactoryGirl.define do
  factory :page do
    association :profile, strategy: :create
    association :shortname, strategy: :build
    association :owner, factory: :profile, strategy: :create
    last_accepted Time.now
    visibility Page.visibilities[:open]
  end
end
