# frozen_string_literal: true

FactoryGirl.define do
  factory :forum do
    association :shortname, strategy: :build
    association :page, strategy: :create

    sequence(:name) { |n| "fg_forum#{n}end" }

    locale 'en-GB'

    before(:create) do |forum|
      forum.build_edge(user: build(:user), parent: forum.page.edge)
      forum.shortname.shortname = forum.name
    end
  end
end
