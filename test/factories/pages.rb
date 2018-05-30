# frozen_string_literal: true

FactoryGirl.define do
  sequence :page_name do |n|
    "fg_page#{n}end"
  end

  factory :page do
    last_accepted Time.current
    visibility Page.visibilities[:open]
    is_published true

    before(:create) do |page|
      page.publisher ||= build(:user)
      page.creator ||= page.publisher.profile
      page.profile ||= build(:profile, profileable: page)
      page.profile.name = generate(:page_name) if page.profile.name.blank?
      page.shortname = build(:shortname) if page.shortname&.shortname&.nil?
      page.is_published = true
    end

    after(:build) do |page|
      page.url ||= build(:shortname).shortname
    end
  end
end
