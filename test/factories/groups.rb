# frozen_string_literal: true

FactoryGirl.define do
  factory :group do
    sequence(:name) { |i| "fg_groups#{i}end" }
    sequence(:name_singular) { |i| "fg_group#{i}end" }
  end
end
