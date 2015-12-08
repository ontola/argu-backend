FactoryGirl.define do
  factory :page do
    association :profile, strategy: :create
    association :shortname, strategy: :build
    association :owner, factory: :profile_direct_email, strategy: :create
    last_accepted Time.current
    visibility Page.visibilities[:open]
  end
end
