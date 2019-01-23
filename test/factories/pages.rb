# frozen_string_literal: true

FactoryBot.define do
  sequence :page_name do |n|
    "fg_page#{n}end"
  end

  factory :page do
    last_accepted Time.current
    visibility Page.visibilities[:visible]
    is_published true
    sequence :url do |n|
      "page_#{n}"
    end
    sequence :profile_attributes do |n|
      {name: "page_#{n}"}
    end
  end
end
