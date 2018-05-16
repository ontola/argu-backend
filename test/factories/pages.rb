# frozen_string_literal: true

FactoryGirl.define do
  sequence :page_name do |n|
    "fg_page#{n}end"
  end

  factory :page do
    owner { passed_in?(:owner) ? owner : build(:profile, profileable: build(:user)) }
    last_accepted Time.current
    visibility Page.visibilities[:open]
    edge { Edge.new(is_published: true, root_id: SecureRandom.uuid) }

    before(:create) do |page|
      page.profile ||= build(:profile, profileable: page)
      page.profile.name = generate(:page_name) if page.profile.name.blank?
    end

    after(:build) do |page|
      page.edge.root_id = page.edge.uuid
      page.edge.user ||= page.publisher
      page.url ||= build(:shortname).shortname
    end
  end
end
