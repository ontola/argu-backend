# frozen_string_literal: true

FactoryBot.define do
  sequence :page_name do |n|
    "fg_page#{n}end"
  end

  factory :page do
    association :profile
    is_published { true }
    language { :en }
    tier { :standard }
    sequence :url do |n|
      "page_#{n}"
    end
    sequence :name do |n|
      "page_#{n}"
    end
  end
end
