# frozen_string_literal: true

FactoryBot.define do
  factory :forum do
    sequence(:name) { |n| "fg_forum#{n}end" }
  end
end
