# frozen_string_literal: true

FactoryGirl.define do
  factory :source do
    association :shortname, strategy: :build
    association :page
    sequence(:name) { |n| "fg_source_#{n}" }
    iri_base 'whitelist'
  end
end
