# frozen_string_literal: true

FactoryGirl.define do
  sequence :page_name do |n|
    "fg_page#{n}end"
  end

  factory :page do
    association :profile,
                strategy: :create
    association :shortname,
                strategy: :build
    owner { passed_in?(:owner) ? owner : create(:profile) }
    last_accepted Time.current
    visibility Page.visibilities[:open]

    before(:create) do |page|
      page.edge = Edge.new(owner: page, user: page.publisher, is_published: true) if page.edge.blank?
      page.profile.update name: generate(:page_name)
    end
  end
end
