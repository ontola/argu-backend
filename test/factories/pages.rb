FactoryGirl.define do
  sequence :page_name do |n|
    "fg_page#{n}"
  end

  factory :page do
    association :profile,
                strategy: :create
    association :shortname,
                strategy: :build
    association :owner,
                factory: :profile_direct_email,
                strategy: :create
    last_accepted Time.current
    visibility Page.visibilities[:open]

    before(:create) do |page, evaluator|
      page.profile.update name: generate(:page_name)
    end
  end
end
