FactoryGirl.define do
  sequence :page_name do |n|
    "fg_page#{n}"
  end

  factory :page do
    association :profile,
                strategy: :create
    association :shortname,
                strategy: :build
    owner { passed_in?(:owner) ? owner : create(:profile_direct_email) }
    last_accepted Time.current
    visibility Page.visibilities[:open]

    before(:create) do |page|
      page.profile.update name: generate(:page_name)
    end
  end
end
