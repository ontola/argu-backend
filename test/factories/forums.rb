# frozen_string_literal: true

FactoryGirl.define do
  factory :forum do
    association :page, strategy: :create

    sequence(:name) { |n| "fg_forum#{n}end" }

    locale 'en-GB'
  end
end
