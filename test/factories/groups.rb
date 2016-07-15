# frozen_string_literal: true
FactoryGirl.define do
  factory :group do
    sequence(:name) { |i| "fg_groups#{i}end" }
    name_singular 'Group'
    visibility :hidden
  end
end
