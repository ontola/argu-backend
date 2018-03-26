# frozen_string_literal: true

FactoryGirl.define do
  sequence :page_name do |n|
    "fg_page#{n}end"
  end

  factory :page do
    association :shortname,
                strategy: :build
    owner { passed_in?(:owner) ? owner : build(:profile, profileable: build(:user)) }
    last_accepted Time.current
    visibility Page.visibilities[:open]

    before(:create) do |page|
      page.profile ||= build(:profile, profileable: page)
      page.edge ||= Edge.new(owner: page, user: page.publisher, is_published: true)
      page.profile.name = generate(:page_name) if page.profile.name.blank?
    end
  end
end
